# regression.do
# Script chạy regression cho DES với DPI-C reference model

# Compile DPI-C nếu có
if {[file exists ./TB/des_ref.c]} {

    # Đường dẫn gcc, chỉnh lại nếu khác
    set gcc "C:/msys64/ucrt64/bin/gcc.exe"
    exec "C:/msys64/ucrt64/bin/gcc.exe" -c -fPIC ./TB/des_ref.c -o des_ref.o
    exec "C:/msys64/ucrt64/bin/gcc.exe" -shared -o des_ref.dll des_ref.o
}

# Dọn dẹp logs cũ
if {[file exists logs]} {
    foreach f [glob -nocomplain -directory logs *] {
        file delete -force $f
    }
    file delete -force logs
}

file mkdir logs

# Xóa file coverage tổng hợp cũ nếu có
file delete -force all_tests.ucdb

# Danh sách các test cần chạy
set TESTS {ENCRYPTION DECRYPTION RANDOM}

# Chạy từng test
foreach t $TESTS {
    # Compile HDL mỗi test (có thể giữ nguyên work nếu muốn)
    vlib work
    vlog +cover ./RTL/DES_core.sv ./TB/testbench.sv

    # Transcript log riêng
    transcript file logs/$t.log

    # Chạy mô phỏng với hoặc không có thư viện DPI
    if {[file exists des_ref.dll]} {
        vsim -c -coverage work.tb_top_des \
             -sv_lib des_ref \
             +TESTNAME=$t \
             -onfinish final \
             -do "run -all; coverage save -onexit $t.ucdb;"
    } else {
        vsim -c -coverage work.tb_top_des \
             +TESTNAME=$t \
             -onfinish final \
             -do "run -all; coverage save -onexit $t.ucdb;"
    }

    transcript file ""
}

# Merge tất cả coverage lại thành một file duy nhất
vcover merge all_tests.ucdb *.ucdb

if {[file exists all_tests.ucdb]} {
    vcover report -html -htmldir covhtmlreport all_tests.ucdb
} else {
    puts "Không tìm thấy file all_tests.ucdb để tạo báo cáo coverage!"
}
