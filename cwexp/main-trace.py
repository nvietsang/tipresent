import sys
import random
import numpy as np
import chipwhisperer as cw
from tqdm import tqdm

def gen_shares_p(p: list):
    l = len(p)
    assert l == 8
    s1 = list(random.randbytes(l))
    s2 = list(random.randbytes(l))
    s3 = [p[i] ^ s1[i] ^ s2[i] for i in range(l)]
    return s1 + s2 + s3

def combine_shares_p(sp: list):
    assert len(sp) == 24
    s1 = sp[:8]
    s2 = sp[8:16]
    s3 = sp[16:]
    p = [s1[i] ^ s2[i] ^ s3[i] for i in range(8)]
    return p

def gen_shares_k(k: list):
    l = len(k)
    assert l == 10
    s1 = list(random.randbytes(l))
    s2 = list(random.randbytes(l))
    s3 = [k[i] ^ s1[i] ^ s2[i] for i in range(l)]
    s1 = [0, 0] + s1
    s2 = [0, 0] + s2
    s3 = [0, 0] + s3
    return s1 + s2 + s3

if __name__ == "__main__":
    ntraces         = int(sys.argv[1])
    tracepath       = sys.argv[2]
    plaintextpath   = sys.argv[3]
    keypath         = sys.argv[4]

    PLATFORM = "CWLITEARM"
    scope = cw.scope()

    # SS_VER == "SS_VER_2_1":
    target_type = cw.targets.SimpleSerial2
    target = cw.target(scope, target_type)
    print("INFO: Found ChipWhisperer😍")

    # CWLITEARM
    prog = cw.programmers.STM32FProgrammer
    scope.default_setup()

    fw_path = f"simpleserial-present/simpleserial-present-{PLATFORM}.hex"
    cw.program_target(scope, prog, fw_path)

    target.flush()
    target.reset_comms()

    # plaintext = [0x6e, 0x10, 0x77, 0x7e, 0x06, 0x29, 0xba, 0x06,
	#              0xf4, 0xe5, 0x82, 0xfc, 0x5e, 0x26, 0xb4, 0x41,
	#              0x9a, 0xf5, 0xf5, 0x82, 0x58, 0x0f, 0x0e, 0x47]
    # key = [0x00, 0x00, 0x8d, 0x0a, 0x32, 0xb5, 0x76, 0x74, 0x7c, 0xc0, 0xde, 0x2e,
	#        0x00, 0x00, 0x24, 0x34, 0x33, 0x56, 0x9a, 0x8c, 0xf8, 0x9e, 0x08, 0x9d,
	#        0x00, 0x00, 0xa9, 0x3e, 0x01, 0xe3, 0xec, 0xf8, 0x84, 0x5e, 0xd6, 0xb3]
    # data = bytearray(plaintext + key)

    p = [0]*8
    k = [0]*10


    # ntraces = 1000
    samples_per_trace = 24400
    scope.adc.samples = samples_per_trace
    scope.clock.adc_src = 'clkgen_x1'
    ssta = 380
    send = 22200

    fp = open(plaintextpath, "w")
    fk = open(keypath, "w")

    for i in tqdm(range(ntraces)):
        # shares_p = plaintext
        # shares_k = key
        shares_p = gen_shares_p(list(random.randbytes(8)))
        # shares_k = gen_shares_k(k)
        shares_k = gen_shares_k(list(random.randbytes(10)))
        data = bytearray(shares_p + shares_k)
        assert len(data) == 60

        # Measure trace
        scope.arm()
        target.simpleserial_write('a', data)
        scope.capture()
        trace = scope.get_last_trace()
        # plt.plot(trace)
        # plt.show()

        response = target.simpleserial_read('r', 64, end='\n', timeout=250)
        # print(response)
        # c = combine_shares_p(list(response)[:24])
        # print(bytes(c).hex())

        hp = bytes(list(reversed(shares_p[ 0: 8])) +
                   list(reversed(shares_p[ 8:16])) +
                   list(reversed(shares_p[16:24]))).hex()
        hk = bytes(list(reversed(shares_k[ 2:12])) + 
                   list(reversed(shares_k[14:24])) + 
                   list(reversed(shares_k[26:36]))).hex()
        fp.write(hp+"\n")
        fk.write(hk+"\n")
        np.save(f"{tracepath}/{i:05d}.npy", trace[ssta:send])

    fp.close()
    fk.close()

    scope.dis()
    target.dis()