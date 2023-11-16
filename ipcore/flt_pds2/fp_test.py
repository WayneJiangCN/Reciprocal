import struct
import sys
import math
#import pyfma
import numpy as np
from mpmath import *

sum = 0
cnt = 0
mp.prec = 65 # 65 is enough for ulp calculation

def binary_to_half(binary):
    return struct.unpack('!e', struct.pack('!H', int(binary, 2)))[0]

def float_to_binary16(num):
    return format(struct.unpack('!H', struct.pack('!e', num))[0], '016b')

def binary_to_float(binary):
    return struct.unpack('!f', struct.pack('!I', int(binary, 2)))[0]

def float_to_binary32(num):
    return format(struct.unpack('!I', struct.pack('!f', num))[0], '032b')

def binary_to_double(binary):
    return struct.unpack('!d', struct.pack('!Q', int(binary, 2)))[0]

def float_to_binary64(num):
    return format(struct.unpack('!Q', struct.pack('!d', num))[0], '064b')

def binary16_is_denorm(num):
    return num[1:6] == '00000'

def binary32_is_denorm(num):
    return num[1:9] == '00000000'

def binary64_is_denorm(num):
    return num[1:12] == '00000000000'

def fp_test(op_sel, prec, result_prec, int_type, line, b2f, f2b, np_2f, binary_is_denorm, man_width):
    global cnt
    cnt = cnt + 1
    # if op_sel == "0": # abs, too simple, we don't test it
    if op_sel == '1': # accum
        global sum
        LSB = -31
        a_tlast, operation_binary, a_binary, result_tlast, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_float = b2f(result_binary)
        if np.isnan(a_float):
            a_float_divide_by_LSB = 0 # arbitrarily assign a value to a_float_divide_by_LSB
        elif np.isinf(a_float):
            a_float_divide_by_LSB = 0 # arbitrarily assign a value to a_float_divide_by_LSB
        else:
            a_float_divide_by_LSB = round(a_float / math.pow(2, LSB))
        if operation_binary == "00000000":
            sum = sum + a_float_divide_by_LSB
        elif operation_binary == "00000001":
            sum = sum - a_float_divide_by_LSB
        golden_float = np_2f(sum) * math.pow(2, LSB)
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if np.isnan(a_float):
            sum = float('nan')
        elif np.isinf(a_float):
            sum = a_float
        if a_tlast == "1":
            sum = 0
        if golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_minus_result = 0
        else:
            golden_minus_result = int(golden_binary, 2) - int(result_binary, 2)
        if a_tlast == "1" and result_tlast == "1":
            a_tlast_minus_result_tlast = 0
        elif a_tlast == "0" and result_tlast == "0":
            a_tlast_minus_result_tlast = 0
        elif a_tlast == "1" and result_tlast == "0":
            a_tlast_minus_result_tlast = 1
        elif a_tlast == "0" and result_tlast == "1":
            a_tlast_minus_result_tlast = -1
        if golden_minus_result != 0:
            print("{:10}, {:5}, {:15}, {:25}, {:25}, {:25}, {:10}".format(cnt, a_tlast_minus_result_tlast, golden_minus_result, golden_float, result_float, a_float, operation_binary))
    elif op_sel == '2': # addsub
        operation_binary, b_binary, a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_float = b2f(result_binary)
        if binary_is_denorm(b_binary):
            b_float = 0.0
        else:
            if operation_binary == "00000000":
                b_float = b2f(b_binary)
            elif operation_binary == "00000001":
                b_float = -b2f(b_binary)
        golden_float = np_2f(a_float + b_float)
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_minus_result = 0
        else:
            golden_minus_result = int(golden_binary, 2) - int(result_binary, 2)
        if golden_minus_result != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}, {:25}, {:10}".format(cnt, golden_minus_result, golden_float, result_float, a_float, b_float, operation_binary))
    elif op_sel == '3': # comp
        operation_binary, b_binary, a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        if binary_is_denorm(b_binary):
            b_float = 0.0
        else:
            b_float = b2f(b_binary)
        if operation_binary == "00000100": # unordered
            golden_bool = np.isnan(a_float) or np.isnan(b_float)
        elif operation_binary == "00001100": # less than
            golden_bool = a_float < b_float
        elif operation_binary == "00010100": # equal
            golden_bool = a_float == b_float
        elif operation_binary == "00011100": # less than or equal
            golden_bool = a_float <= b_float
        elif operation_binary == "00100100": # greater than
            golden_bool = a_float > b_float
        elif operation_binary == "00101100": # not equal
            golden_bool = a_float != b_float
        elif operation_binary == "00110100": # greater than or equal
            golden_bool = a_float >= b_float
        # condition code is not included
        golden_minus_result = int(golden_bool) - int(result_binary, 2)
        if golden_minus_result != 0:
            print("{:10}, {:5}, {:5}, {:5}, {:25}, {:25}, {:10}".format(cnt, golden_minus_result, golden_bool, result_binary, a_float, b_float, operation_binary))
    elif op_sel == '4': # div
        b_binary, a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_float = b2f(result_binary)
        if binary_is_denorm(b_binary):
            b_float = 0.0
        else:
            b_float = b2f(b_binary)
        if (b_float == 0):
            golden_float = float('nan')
        else:
            golden_float = np_2f(a_float / b_float)
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_minus_result = 0
        else:
            golden_minus_result = int(golden_binary, 2) - int(result_binary, 2)
        if golden_minus_result != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}, {:25}".format(cnt, golden_minus_result, golden_float, result_float, a_float, b_float))
    elif op_sel == '5': # exp
        a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_float = b2f(result_binary)
        golden_float = np_2f(math.exp(a_float))
        golden_float_mp = exp(mpf(a_float))
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            gt_1_ulp = 0
        elif (int(golden_binary, 2) - int(result_binary, 2)) == 0:
            gt_1_ulp = 0
        elif abs(fsub(golden_float_mp, result_float)) <= (math.ulp(result_float) * math.pow(2, (52-man_width))): # less than or equal to 1 ulp
            gt_1_ulp = 0
        else:
            gt_1_ulp = int(golden_binary, 2) - int(result_binary, 2)
        print("{:10}, {:15}, {:25}, {:25}, {:25}".format(cnt, gt_1_ulp, golden_float, result_float, a_float))
    elif op_sel == '6': # fx2fl
        a_binary, result_binary = line.split()
        if int_type == '1': #uint
            a_int_uint = int(a_binary, 2)
        else: #int
            a_int_uint = struct.unpack('!i', struct.pack('!I', int(a_binary, 2)))[0]
        result_float = b2f(result_binary)
        if result_prec == '1': # single
            golden_float = np.single(float(a_int_uint))
        else: # double
            golden_float = np.double(float(a_int_uint))
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_minus_result = 0
        else:
            golden_minus_result = int(golden_binary, 2) - int(result_binary, 2)
        if golden_minus_result != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}, {:35}".format(cnt, golden_minus_result, golden_float, result_float, a_int_uint, a_binary))
    elif op_sel == '7': # fl2fx
        a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_int = struct.unpack('!i', struct.pack('!I', int(result_binary, 2)))[0]
        if a_float == float('inf'):
            golden_int = 2147483647
        elif a_float == float('-inf'):
            golden_int = -2147483648
        else:
            if a_float > 0 and np.int32(np_2f(a_float)) == -2147483648:
                golden_int = 2147483647
            elif a_float < 0 and np.int32(np_2f(a_float)) == -2147483648:
                golden_int = -2147483648
            else:
                golden_int = np.int32(np_2f(a_float))
        golden_minus_result = golden_int - result_int
        if golden_minus_result != 0:
            print("{:10}, {:15}, {:40}, {:40}, {:25}".format(cnt, golden_minus_result, golden_int, result_int, a_float))
    elif op_sel == '8': # fl2fl
        a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_float = b2f(result_binary)
        if result_prec == '1': # single
            golden_float = np.single(a_float)
            golden_binary = float_to_binary32(golden_float)
        else: # double
            golden_float = np.double(a_float)
            golden_binary = float_to_binary64(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_minus_result = 0
        else:
            golden_minus_result = int(golden_binary, 2) - int(result_binary, 2)
        if golden_minus_result != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}".format(cnt, golden_minus_result, golden_float, result_float, a_float))
    elif op_sel == '9': # fma
        operation_binary, c_binary, b_binary, a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = np.longdouble(0)
        else:
            a_float = b2f(a_binary)
        if binary_is_denorm(b_binary):
            b_float = np.longdouble(0)
        else:
            b_float = b2f(b_binary)
        if binary_is_denorm(c_binary):
            c_float = np.longdouble(0)
        else:
            if operation_binary == "00000000":
                c_float = b2f(c_binary)
            elif operation_binary == "00000001":
                c_float = -b2f(c_binary)
        result_float = b2f(result_binary)
        golden_float = np_2f(pyfma.fma(a_float, b_float, c_float))
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if np.isnan(golden_float) and np.isnan(result_float):
            golden_minus_result = 0
        elif golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_minus_result = 0
        else:
            golden_minus_result = int(golden_binary, 2) - int(result_binary, 2)
        if golden_minus_result != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}, {:25}, {:25}, {:10}".format(cnt, golden_minus_result, golden_float, result_float, a_float, b_float, c_float, operation_binary))
    elif op_sel == '10': # log
        a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_float = b2f(result_binary)
        if a_float != 0:
            golden_float = np_2f(math.log(a_float))
            golden_float_mp = log(mpf(a_float))
        else:
            golden_float = float('-inf')
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            gt_1_ulp = 0
        elif (int(golden_binary, 2) - int(result_binary, 2)) == 0:
            gt_1_ulp = 0
        elif abs(fsub(golden_float_mp, result_float)) <= (math.ulp(result_float) * math.pow(2, (52-man_width))): # less than or equal to 1 ulp
            gt_1_ulp = 0
        else:
            gt_1_ulp = int(golden_binary, 2) - int(result_binary, 2)
        if gt_1_ulp != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}".format(cnt, gt_1_ulp, golden_float, result_float, a_float))
    elif op_sel == '11': # mul
        b_binary, a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        if binary_is_denorm(b_binary):
            b_float = 0.0
        else:
            b_float = b2f(b_binary)
        result_float = b2f(result_binary)
        golden_float = np_2f(a_float * b_float)
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if np.isnan(golden_float) and np.isnan(result_float):
            golden_minus_result = 0
        elif golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_minus_result = 0
        else:
            golden_minus_result = int(golden_binary, 2) - int(result_binary, 2)
        if golden_minus_result != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}, {:25}".format(cnt, golden_minus_result, golden_float, result_float, a_float, b_float))
    elif op_sel == '12': # inv
        a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_float = b2f(result_binary)
        if (a_float == 0):
            golden_float = float('nan')
        else:
            golden_float = np_2f(1 / a_float)
            golden_float_mp = mpf(a_float) ** mpf('-1')
        golden_binary = f2b(golden_float)
        #print(golden_float)
        #print(np.isnan(golden_float))
        #print(np.isnan(result_float))
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if np.isnan(golden_float) and np.isnan(result_float):
            gt_1_ulp = 0
        elif golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            gt_1_ulp = 0
        elif (int(golden_binary, 2) - int(result_binary, 2)) == 0:
            gt_1_ulp = 0
        elif abs(fsub(golden_float_mp, result_float)) <= (math.ulp(result_float) * math.pow(2, (52-man_width))): # less than or equal to 1 ulp
            gt_1_ulp = 0
        else:
            gt_1_ulp = int(golden_binary, 2) - int(result_binary, 2)
        if gt_1_ulp != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}".format(cnt, gt_1_ulp, golden_float, result_float, a_float))
    elif op_sel == '13': # invsqrt
        a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        # rtl
        result_float = b2f(result_binary)
        # golden
        if a_float < 0:
            golden_float = float('nan')
        elif math.sqrt(a_float) == 0:
            golden_float = float('nan')
        else:
            golden_float = np_2f(1 / math.sqrt(a_float))
            golden_float_mp = 1 / (mpf(a_float) ** mpf('0.5'))
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if np.isnan(golden_float) and np.isnan(result_float):
            gt_1_ulp = 0
        elif golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            gt_1_ulp = 0
        elif (int(golden_binary, 2) - int(result_binary, 2)) == 0:
            gt_1_ulp = 0
        elif abs(fsub(golden_float_mp, result_float)) <= (math.ulp(result_float) * math.pow(2, (52-man_width))): # less than or equal to 1 ulp
            gt_1_ulp = 0
        else:
            gt_1_ulp = int(golden_binary, 2) - int(result_binary, 2)
            # if (int(golden_binary, 2) - int(result_binary, 2)) == 1: # golden is xxx1 and result is xxx0 (xxx means unimportant bits)
            #     if golden_1bit_more_prec == 1: # if the value xxx1 of golden is rounded from xxx0.1xxx
            #         gt_1_ulp = 0 # then the result satisfies 1 ulp
            #     else: # if golden_1bit_more_prec == 0, i.e. if the value xxx1 of golden is rounded from xxx1.0xxx
            #         gt_1_ulp = 1 # then the result does NOT satisfy 1 ulp
            # elif (int(golden_binary, 2) - int(result_binary, 2)) == -1: # golden is xxx0 and result is xxx1 (xxx means unimportant bits)
            #     if golden_1bit_more_prec == 1: # if the value xxx0 of golden is rounded from xxx1.1xxx
            #         gt_1_ulp = 1 # then the result does NOT satisfy 1 ulp
            #     else: # if golden_1bit_more_prec == 0, i.e. if the value xxx0 of golden is rounded from xxx0.0xxx
            #         gt_1_ulp = 0 # then the result satisfies 1 ulp
            # else: # the absolute value of the difference is greater than 1
            #     gt_1_ulp = int(golden_binary, 2) - int(result_binary, 2)
        # golden taylor
        if prec == '1': # single
            a = 1 + int(a_binary[9:12], 2) * (2**(-3)) + (2**(-4))
            if a_binary[8:9] == '1':
                a_exp_even_odd = 1
                golden_taylor_exp = - ((int(a_binary[1:9], 2) - 127) / 2) - 1
            else:
                a_exp_even_odd = math.pow(2, -0.5)
                golden_taylor_exp = - ((int(a_binary[1:9], 2) - 1 - 127) / 2) - 1
            x_man_int = int(a_binary[9:32], 2)
            x_minus_a = x_man_int * (2**(-23)) - (a-1)
        if prec == '2': # double
            a = 1 + int(a_binary[12:18], 2) * (2**(-6)) + (2**(-7))
            if a_binary[11:12] == '1':
                a_exp_even_odd = 1
                golden_taylor_exp = - ((int(a_binary[1:12], 2) - 1023) / 2) - 1
            else:
                a_exp_even_odd = math.pow(2, -0.5)
                golden_taylor_exp = - ((int(a_binary[1:12], 2) - 1 - 1023) / 2) - 1
            x_man_int = int(a_binary[12:64], 2)
            x_minus_a = x_man_int * (2**(-52)) - (a-1)
        a0 = a_exp_even_odd *                                        math.pow(a, -0.5)
        a1 = a_exp_even_odd * (1        /(2**1))         * (1/(1)) * math.pow(a, -1.5)
        a2 = a_exp_even_odd * (1*3      /(2**2))       * (1/(2*1)) * math.pow(a, -2.5)
        a3 = a_exp_even_odd * (1*3*5    /(2**3))     * (1/(3*2*1)) * math.pow(a, -3.5)
        a4 = a_exp_even_odd * (1*3*5*7  /(2**4))   * (1/(4*3*2*1)) * math.pow(a, -4.5)
        a5 = a_exp_even_odd * (1*3*5*7*9/(2**5)) * (1/(5*4*3*2*1)) * math.pow(a, -5.5)
        a6 = a_exp_even_odd * (1*3*5*7*9*11/(2**6)) * (1/(6*5*4*3*2*1)) * math.pow(a, -6.5)
        golden_taylor_frac = 2 * (a0 - a1 * x_minus_a + a2 * (x_minus_a**2) - a3 * (x_minus_a**3) + a4 * (x_minus_a**4) - a5 * (x_minus_a**5) - a6 * (x_minus_a**6))
        golden_taylor_float = golden_taylor_frac * (2**golden_taylor_exp)
        golden_taylor_binary = f2b(np_2f(golden_taylor_float))
        if binary_is_denorm(golden_taylor_binary):
            golden_taylor_float = 0.0
        if np.isnan(golden_taylor_float) and np.isnan(result_float):
            golden_taylor_minus_result = 0
        elif golden_taylor_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_taylor_minus_result = 0
        else:
            golden_taylor_minus_result = int(golden_taylor_binary, 2) - int(result_binary, 2)
        if gt_1_ulp != 0:
            print("{:10}, {:15}, {:15}, {:25}, {:25}, {:25}, {:25}".format(cnt, gt_1_ulp, golden_taylor_minus_result, golden_float, golden_taylor_float, result_float, a_float))
    elif op_sel == '14': # sqrt
        a_binary, result_binary = line.split()
        if binary_is_denorm(a_binary):
            a_float = 0.0
        else:
            a_float = b2f(a_binary)
        result_float = b2f(result_binary)
        if a_float < 0:
            golden_float = float('nan')
        else:
            golden_float = np_2f(math.sqrt(a_float))
        golden_binary = f2b(golden_float)
        if binary_is_denorm(golden_binary):
            golden_float = 0.0
        if np.isnan(golden_float) and np.isnan(result_float):
            golden_minus_result = 0
        elif golden_float == 0 and result_float == 0: # in case that binary of -0 and +0 unequal
            golden_minus_result = 0
        else:
            golden_minus_result = int(golden_binary, 2) - int(result_binary, 2)
        if golden_minus_result != 0:
            print("{:10}, {:15}, {:25}, {:25}, {:25}".format(cnt, golden_minus_result, golden_float, result_float, a_float))

if __name__ == '__main__':
    if sys.argv[1] == "1": # accum
        print("{:^10}  {:^5}  {:^15}  {:^25}  {:^25}  {:^25}  {:^10}".format("cnt", "tlast_diff", "diff", "golden_float", "result_float", "a_float", "op_binary"))
    elif sys.argv[1] == '2': # addsub
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}  {:^25}  {:^10}".format("cnt", "diff", "golden_float", "result_float", "a_float", "b_float", "op_binary"))
    elif sys.argv[1] == '3': # comp
        print("{:^10}  {:^5}  {:^15}  {:^15}  {:^25}  {:^25}  {:^10}".format("cnt", "diff", "golden_bool", "result_binary", "a_float", "b_float", "op_binary"))
    elif sys.argv[1] == '4': # div
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "golden_float", "result_float", "a_float", "b_float"))
    elif sys.argv[1] == '5': # exp
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "golden_float", "result_float", "a_float"))
    elif sys.argv[1] == '6': # fx2fl
        if sys.argv[4] == '1': #uint
            print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}  {:^35}".format("cnt", "diff", "golden_float", "result_float", "a_uint", "a_binary"))
        else: #int
            print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}  {:^35}".format("cnt", "diff", "golden_float", "result_float", "a_int", "a_binary"))
    elif sys.argv[1] == '7': # fl2fx
        print("{:^10}  {:^15}  {:^40}  {:^40}  {:^25}".format("cnt", "diff", "golden_int", "result_int", "a_float"))
    elif sys.argv[1] == '8': # fl2fl
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "golden_float", "result_float", "a_float"))
    elif sys.argv[1] == '9': # fma
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "golden_float", "result_float", "a_float", "b_float", "c_float"))
    elif sys.argv[1] == '10': # log
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "golden_float", "result_float", "a_float"))
    elif sys.argv[1] == '11': # mul
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "golden_float", "result_float", "a_float", "b_float"))
    elif sys.argv[1] == '12': # inv
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "golden_float", "result_float", "a_float"))
    elif sys.argv[1] == '13': # invsqrt
        print("{:^10}  {:^15}  {:^15}  {:^25}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "diff_taylor", "golden_float", "golden_taylor_float", "result_float", "a_float"))
    elif sys.argv[1] == '14': # sqrt
        print("{:^10}  {:^15}  {:^25}  {:^25}  {:^25}".format("cnt", "diff", "golden_float", "result_float", "a_float"))
    for line in sys.stdin:
        if line == '': # If empty string is read then stop the loop
            break
        if len(sys.argv) == 5:
            if sys.argv[2] == '0': # half
                fp_test(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], line, binary_to_half, float_to_binary16, np.half, binary16_is_denorm, 10)
            elif sys.argv[2] == '1': # single
                fp_test(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], line, binary_to_float, float_to_binary32, np.single, binary32_is_denorm, 23)
            else: # double
                fp_test(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], line, binary_to_double, float_to_binary64, np.double, binary64_is_denorm, 52)
