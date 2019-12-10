#!/usr/bin/env python3
"""

Suppose  you are a party with n people [0, ..., n-1]
Among them exists one celebrity, such that all other n-1
know them but they don't know her

Given a function `bool knows(a, b)` implement `int findCelebrity(n)`

There will be exactly one celebrity if there is one at all,

else return -1 if
no celebrity

>>> test2 = [[0, 0, 1, 0], [0, 0, 1, 0], [0, 0, 0, 0], [0, 0, 1, 0]]

# C is the Celebrity because everyone "knows" C
# but C doesn't know anyone
#
#         0   1   2   3
#        (A) (B) (C) (D)
# 0 (A)  [0,  0,  1,  0]
# 1 (B)  [0,  0,  1,  0]
# 2 (C)  [0,  0,  0,  0]
# 3 (D)  [0,  0,  1,  0]

"""

test1 = [[1, 1, 0], [0, 1, 0], [1, 1, 1]]

test2 = [[0, 0, 1, 0], [0, 0, 1, 0], [0, 0, 0, 0], [0, 0, 1, 0]]

test3 = [
    [0, 0, 1, 0, 1, 0],
    [1, 1, 1, 0, 1, 0],
    [0, 1, 1, 0, 1, 0],
    [0, 0, 0, 0, 1, 0],
    [0, 0, 1, 1, 1, 0],
    [1, 0, 1, 1, 1, 0],
]


test4 = [
    [0, 0, 0, 1, 1, 1, 0, 1, 0, 1],
    [0, 0, 0, 1, 1, 1, 0, 1, 0, 1],
    [1, 1, 0, 1, 1, 1, 0, 1, 0, 1],
    [0, 1, 0, 1, 1, 1, 0, 1, 0, 1],
    [0, 0, 0, 1, 1, 1, 0, 0, 0, 1],
    [0, 0, 0, 1, 1, 1, 0, 0, 0, 1],
    [0, 0, 0, 1, 1, 1, 0, 1, 1, 1],
    [1, 0, 0, 1, 1, 1, 0, 1, 1, 1],
    [1, 0, 0, 1, 1, 1, 0, 1, 1, 1],
    [1, 0, 0, 1, 1, 1, 0, 1, 1, 1],
]


def Solution(party):
    people = len(party)

    def knows(a: int, b: int) -> bool:
        # Know if cell is 1, and can't know self

        if a <= people and b <= people:
            print(a)
            print(people)
            print(party[a])
            print(party[a][b])
            print(a <= people and b <= people)
            print("fuck2")
            return True if party[a][b] == 1 and not a == b else False
        else:
            print("Too many people")
            return False
            # raise ValueError("Too many people")

    # test2; knows(3,0) -> Does C know A ? -> False (0)
    # test2; knows(0,3) -> Does A know C ? -> True (1)
    # test3; knows(2,0) -> Does C know A ? -> True (1)
    # test3; knows(0,2) -> Does A know C ? -> False (0)
    # test3; knows(1,2) -> Does A know C ? -> False (0)
    # test3; knows(0,1) -> Does A know C ? -> True (1)
    # test3; knows(1,1) -> Does A know C ? -> False (1) (Can't know self)
    # knows(7000, 0)
    knows(3, 4)
    knows(8, 3)

    print("fuck")


Solution(test4)
# Solution(test2)
# doctest.mod()
# print(test2)
print("rootfuck")
