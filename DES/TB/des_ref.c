/*
 * des_ref.c
 *
 * Golden reference model for single DES ECB block operation.
 * Intended for SystemVerilog DPI-C scoreboard integration.
 *
 * SV DPI example:
 *   import "DPI-C" function longint unsigned des_encrypt_ref(
 *       input longint unsigned data,
 *       input longint unsigned key
 *   );
 *
 *   import "DPI-C" function longint unsigned des_decrypt_ref(
 *       input longint unsigned data,
 *       input longint unsigned key
 *   );
 *
 * Notes:
 *   - Input/output data are 64-bit blocks.
 *   - Key is a 64-bit DES key including parity bits.
 *   - DES PC1 removes parity bits internally.
 *   - No padding/mode is implemented; this is one DES block only.
 */
// #define DES_REF_STANDALONE_TEST
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Initial Permutation */
static const int DES_IP[64] = {
    58,50,42,34,26,18,10, 2,
    60,52,44,36,28,20,12, 4,
    62,54,46,38,30,22,14, 6,
    64,56,48,40,32,24,16, 8,
    57,49,41,33,25,17, 9, 1,
    59,51,43,35,27,19,11, 3,
    61,53,45,37,29,21,13, 5,
    63,55,47,39,31,23,15, 7
};

/* Final Permutation / inverse IP */
static const int DES_FP[64] = {
    40, 8,48,16,56,24,64,32,
    39, 7,47,15,55,23,63,31,
    38, 6,46,14,54,22,62,30,
    37, 5,45,13,53,21,61,29,
    36, 4,44,12,52,20,60,28,
    35, 3,43,11,51,19,59,27,
    34, 2,42,10,50,18,58,26,
    33, 1,41, 9,49,17,57,25
};

/* Expansion permutation E */
static const int DES_E[48] = {
    32, 1, 2, 3, 4, 5,
     4, 5, 6, 7, 8, 9,
     8, 9,10,11,12,13,
    12,13,14,15,16,17,
    16,17,18,19,20,21,
    20,21,22,23,24,25,
    24,25,26,27,28,29,
    28,29,30,31,32, 1
};

/* P permutation after S-box substitution */
static const int DES_P[32] = {
    16, 7,20,21,
    29,12,28,17,
     1,15,23,26,
     5,18,31,10,
     2, 8,24,14,
    32,27, 3, 9,
    19,13,30, 6,
    22,11, 4,25
};

/* Permuted Choice 1 */
static const int DES_PC1[56] = {
    57,49,41,33,25,17, 9,
     1,58,50,42,34,26,18,
    10, 2,59,51,43,35,27,
    19,11, 3,60,52,44,36,
    63,55,47,39,31,23,15,
     7,62,54,46,38,30,22,
    14, 6,61,53,45,37,29,
    21,13, 5,28,20,12, 4
};

/* Permuted Choice 2 */
static const int DES_PC2[48] = {
    14,17,11,24, 1, 5,
     3,28,15, 6,21,10,
    23,19,12, 4,26, 8,
    16, 7,27,20,13, 2,
    41,52,31,37,47,55,
    30,40,51,45,33,48,
    44,49,39,56,34,53,
    46,42,50,36,29,32
};

static const int DES_SHIFTS[16] = {
    1, 1, 2, 2,
    2, 2, 2, 2,
    1, 2, 2, 2,
    2, 2, 2, 1
};

static const uint8_t DES_SBOX[8][4][16] = {
    {
        {14, 4,13, 1, 2,15,11, 8, 3,10, 6,12, 5, 9, 0, 7},
        { 0,15, 7, 4,14, 2,13, 1,10, 6,12,11, 9, 5, 3, 8},
        { 4, 1,14, 8,13, 6, 2,11,15,12, 9, 7, 3,10, 5, 0},
        {15,12, 8, 2, 4, 9, 1, 7, 5,11, 3,14,10, 0, 6,13}
    },
    {
        {15, 1, 8,14, 6,11, 3, 4, 9, 7, 2,13,12, 0, 5,10},
        { 3,13, 4, 7,15, 2, 8,14,12, 0, 1,10, 6, 9,11, 5},
        { 0,14, 7,11,10, 4,13, 1, 5, 8,12, 6, 9, 3, 2,15},
        {13, 8,10, 1, 3,15, 4, 2,11, 6, 7,12, 0, 5,14, 9}
    },
    {
        {10, 0, 9,14, 6, 3,15, 5, 1,13,12, 7,11, 4, 2, 8},
        {13, 7, 0, 9, 3, 4, 6,10, 2, 8, 5,14,12,11,15, 1},
        {13, 6, 4, 9, 8,15, 3, 0,11, 1, 2,12, 5,10,14, 7},
        { 1,10,13, 0, 6, 9, 8, 7, 4,15,14, 3,11, 5, 2,12}
    },
    {
        { 7,13,14, 3, 0, 6, 9,10, 1, 2, 8, 5,11,12, 4,15},
        {13, 8,11, 5, 6,15, 0, 3, 4, 7, 2,12, 1,10,14, 9},
        {10, 6, 9, 0,12,11, 7,13,15, 1, 3,14, 5, 2, 8, 4},
        { 3,15, 0, 6,10, 1,13, 8, 9, 4, 5,11,12, 7, 2,14}
    },
    {
        { 2,12, 4, 1, 7,10,11, 6, 8, 5, 3,15,13, 0,14, 9},
        {14,11, 2,12, 4, 7,13, 1, 5, 0,15,10, 3, 9, 8, 6},
        { 4, 2, 1,11,10,13, 7, 8,15, 9,12, 5, 6, 3, 0,14},
        {11, 8,12, 7, 1,14, 2,13, 6,15, 0, 9,10, 4, 5, 3}
    },
    {
        {12, 1,10,15, 9, 2, 6, 8, 0,13, 3, 4,14, 7, 5,11},
        {10,15, 4, 2, 7,12, 9, 5, 6, 1,13,14, 0,11, 3, 8},
        { 9,14,15, 5, 2, 8,12, 3, 7, 0, 4,10, 1,13,11, 6},
        { 4, 3, 2,12, 9, 5,15,10,11,14, 1, 7, 6, 0, 8,13}
    },
    {
        { 4,11, 2,14,15, 0, 8,13, 3,12, 9, 7, 5,10, 6, 1},
        {13, 0,11, 7, 4, 9, 1,10,14, 3, 5,12, 2,15, 8, 6},
        { 1, 4,11,13,12, 3, 7,14,10,15, 6, 8, 0, 5, 9, 2},
        { 6,11,13, 8, 1, 4,10, 7, 9, 5, 0,15,14, 2, 3,12}
    },
    {
        {13, 2, 8, 4, 6,15,11, 1,10, 9, 3,14, 5, 0,12, 7},
        { 1,15,13, 8,10, 3, 7, 4,12, 5, 6,11, 0,14, 9, 2},
        { 7,11, 4, 1, 9,12,14, 2, 0, 6,10,13,15, 3, 5, 8},
        { 2, 1,14, 7, 4,10, 8,13,15,12, 9, 0, 3, 5, 6,11}
    }
};

/*
 * Generic permutation helper.
 * tbl entries are DES-style 1-based bit positions from MSB to LSB
 * of an input value with bit width equal to in_width.
 */
static uint64_t des_permute(uint64_t in, const int *tbl, int out_width, int in_width)
{
    uint64_t out = 0ULL;

    for (int i = 0; i < out_width; i++) {
        out <<= 1;
        out |= (in >> (in_width - tbl[i])) & 1ULL;
    }

    return out;
}

static uint32_t des_rotl28(uint32_t v, int sh)
{
    return ((v << sh) | (v >> (28 - sh))) & 0x0FFFFFFFUL;
}

static void des_generate_subkeys(uint64_t key, uint64_t subkey[16])
{
    uint64_t pc1 = des_permute(key, DES_PC1, 56, 64);
    uint32_t c = (uint32_t)((pc1 >> 28) & 0x0FFFFFFFUL);
    uint32_t d = (uint32_t)( pc1        & 0x0FFFFFFFUL);

    for (int round = 0; round < 16; round++) {
        c = des_rotl28(c, DES_SHIFTS[round]);
        d = des_rotl28(d, DES_SHIFTS[round]);

        uint64_t cd = (((uint64_t)c) << 28) | (uint64_t)d;
        subkey[round] = des_permute(cd, DES_PC2, 48, 56);
    }
}

static uint32_t des_f(uint32_t r, uint64_t k)
{
    uint64_t e = des_permute((uint64_t)r, DES_E, 48, 32);
    e ^= k;

    uint32_t s_out = 0UL;

    for (int box = 0; box < 8; box++) {
        uint8_t six_bits = (uint8_t)((e >> (42 - 6 * box)) & 0x3FULL);
        int row = ((six_bits & 0x20) >> 4) | (six_bits & 0x01);
        int col = (six_bits >> 1) & 0x0F;

        s_out <<= 4;
        s_out |= DES_SBOX[box][row][col] & 0x0F;
    }

    return (uint32_t)des_permute((uint64_t)s_out, DES_P, 32, 32);
}

static uint64_t des_crypt_block(uint64_t data, uint64_t key, int decrypt)
{
    uint64_t subkey[16];
    des_generate_subkeys(key, subkey);

    uint64_t ip = des_permute(data, DES_IP, 64, 64);
    uint32_t l = (uint32_t)(ip >> 32);
    uint32_t r = (uint32_t)(ip & 0xFFFFFFFFUL);

    for (int round = 0; round < 16; round++) {
        int key_index = decrypt ? (15 - round) : round;

        uint32_t old_r = r;
        r = l ^ des_f(r, subkey[key_index]);
        l = old_r;
    }

    /* DES final swap: R16 || L16 before FP */
    uint64_t preout = (((uint64_t)r) << 32) | (uint64_t)l;
    return des_permute(preout, DES_FP, 64, 64);
}

/* DPI-C callable encryption reference model */
uint64_t des_encrypt_ref(uint64_t data, uint64_t key)
{
    return des_crypt_block(data, key, 0);
}

/* DPI-C callable decryption reference model */
uint64_t des_decrypt_ref(uint64_t data, uint64_t key)
{
    return des_crypt_block(data, key, 1);
}

/* Optional single entry point: decrypt = 0 encrypt, decrypt != 0 decrypt */
uint64_t des_ref_model(uint64_t data, uint64_t key, int decrypt)
{
    return des_crypt_block(data, key, decrypt != 0);
}

#ifdef __cplusplus
}
#endif

#ifdef DES_REF_STANDALONE_TEST
#include <stdio.h>

int main(void)
{
    /* Standard DES known answer test:
     * key       = 0x133457799BBCDFF1
     * plaintext = 0x0123456789ABCDEF
     * cipher    = 0x85E813540F0AB405
     */
    uint64_t key = 0x133457799BBCDFF1ULL;
    uint64_t pt  = 0x0123456789ABCDEFULL;
    uint64_t ct  = des_encrypt_ref(pt, key);
    uint64_t dec = des_decrypt_ref(ct, key);

    printf("key = 0x%016llX\n", (unsigned long long)key);
    printf("pt  = 0x%016llX\n", (unsigned long long)pt);
    printf("ct  = 0x%016llX expected 0x85E813540F0AB405\n", (unsigned long long)ct);
    printf("dec = 0x%016llX expected 0x0123456789ABCDEF\n", (unsigned long long)dec);

    return (ct == 0x85E813540F0AB405ULL && dec == pt) ? 0 : 1;
}
#endif
