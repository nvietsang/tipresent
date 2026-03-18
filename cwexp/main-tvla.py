import time
import random
import pathlib
import numpy as np
import chipwhisperer as cw
import matplotlib.pyplot as plt
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


    ntraces = 10000
    progress = sorted(set([1000, 5000, ntraces]))
    samples_per_trace = 24400
    scope.adc.samples = samples_per_trace
    scope.clock.adc_src = 'clkgen_x4'

    n_fix = 0
    n_rnd = 0
    S1_fix = np.zeros((samples_per_trace,),dtype=np.double)
    S1_rnd = np.zeros((samples_per_trace,),dtype=np.double)
    S2_fix = np.zeros((samples_per_trace,),dtype=np.double)
    S2_rnd = np.zeros((samples_per_trace,),dtype=np.double)

    
    # coinflip = 1

    for i in tqdm(range(ntraces)):
        coinflip = random.getrandbits(1)
        if coinflip:
            # Fix input
            shares_p = gen_shares_p(p)
        else:
            # Random input
            shares_p = gen_shares_p(list(random.randbytes(8)))

        shares_k = gen_shares_k(k)
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
    
        if coinflip:
            n_fix += 1
            S1_fix += trace
            S2_fix += np.square(trace)
        else:
            n_rnd += 1
            S1_rnd += trace
            S2_rnd += np.square(trace)
        if i+1 in progress:
            print("samples: " + str(scope.adc.trig_count))
            # Generate t-test plot
            mu_fix = S1_fix/n_fix
            mu_rnd = S1_rnd/n_rnd
            var_fix = S2_fix/n_fix - np.square(mu_fix)
            var_rnd = S2_rnd/n_rnd - np.square(mu_rnd)
            tscore = np.divide((mu_fix - mu_rnd),np.sqrt(var_fix/n_fix + var_rnd/n_rnd))
            tscore = tscore[:samples_per_trace]
            plt.figure(figsize=(16,9))
            plt.plot(tscore)
            plt.plot([0,len(tscore)-1],[4.5,4.5],'r-')
            plt.plot([0,len(tscore)-1],[-4.5,-4.5],'r-')
            plt.title(str(n_fix+n_rnd))
            plt.xlim((0,len(tscore)))
            # plt.ylim((-10,10))
            pathlib.Path("ttest").mkdir(parents=True, exist_ok=True)
            plt.savefig("ttest/" + PLATFORM + "x4_{}.png".format(n_fix+n_rnd))
            plt.show()

    scope.dis()
    target.dis()