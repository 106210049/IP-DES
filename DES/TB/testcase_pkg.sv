package testcase_pkg;

typedef enum logic [2:0] {
  ENCRYPTION = 3'b001,
  DECRYPTION = 3'b010,
  RANDOM     = 3'b011
} test_case;

endpackage: testcase_pkg