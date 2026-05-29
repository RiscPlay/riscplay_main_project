class Rnd:
    def __init__(self, seed):
        self.seed = seed & 0xFFFF

        self.t1 = 0x1250
        self.t2 = 0xFA00
        self.t3 = self.seed

    def clock(self):
        old_t1 = self.t1
        old_t2 = self.t2
        old_t3 = self.t3

        if old_t3 == 0:
            self.t1 = ((self.seed ^ 0x1250) ^ old_t3) & 0xFFFF
            self.t2 = ((self.seed ^ 0x11F5) ^ old_t1) & 0xFFFF
            self.t3 = ((self.seed ^ 0x02F0) ^ old_t2) & 0xFFFF
        else:
            self.t1 = (old_t3 ^ ((old_t3 << 7) & 0xFFFF)) & 0xFFFF
            self.t2 = (old_t1 ^ (old_t1 >> 9)) & 0xFFFF
            self.t3 = (old_t2 ^ ((old_t2 << 8) & 0xFFFF)) & 0xFFFF

        return self.t3


# TESTE

rnd = Rnd(seed=0x1234)

for i in range(30):
    value = rnd.clock()
    print(f"{i:02d}: 0x{value:04X} ({value})")