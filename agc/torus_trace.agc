# Positive fixed-point trace on the Block II AGC, domain 0..8191.
# Input BUDGET, output TRACE; STATUS=1 on overflow, 0 on success.
BUDGET          EQUALS          0050
TRACE           EQUALS          0051
STATUS          EQUALS          0052
Q               EQUALS          0002

                SETLOC         4000
EXTRACT         CA             BUDGET
                AD             BUDGET
                TS             TRACE
                TCF            SUCCESS
OVERFLOW        CA             ONE
                TS             STATUS
                CA             ZERO
                TS             TRACE
                TC             Q
SUCCESS         CA             ZERO
                TS             STATUS
                TC             Q
ONE             DEC            1
ZERO            DEC            0
