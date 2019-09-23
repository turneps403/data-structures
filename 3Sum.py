#!/usr/local/bin/python
from typing import List

class Solution:
    def threeSum(self, nums: List[int]) -> List[List[int]]:
        neg, pos = [], []
        res = []
        zero_cnt = 0
        for _ in nums:
            if _ < 0:
                neg.append(_)
            elif _ > 0:
                pos.append(_)
            else:
                zero_cnt += 1

        if zero_cnt > 2:
            res.append([0,0,0])
        if zero_cnt:
            pos.append(0)

        nhash = {}
        phash = {}
        already_found = {}
        for p in pos:
            if p in phash:
                phash[p] += 1
            else:
                phash[p] = 1

            for n in neg:
                if n in nhash:
                    nhash[n] += 1
                else:
                    nhash[n] = 1
                if -(p + n) in phash:
                    if -(p + n) != p or phash[p] > 1:
                        solution = [n, -(p + n), p] if -(p + n) < p else [n, p, -(p + n)]
                        if f"{solution}" not in already_found:
                            res.append(solution)
                            already_found[f"{solution}"] = 1

                if -(p + n) in nhash:
                    if -(p + n) != n or nhash[n] > 1:
                        solution = [n, -(p + n), p] if n < -(p + n) else [-(p + n), n, p]
                        if f"{solution}" not in already_found:
                            res.append(solution)
                            already_found[f"{solution}"] = 1
            nhash = {}
        return sorted(res)






if __name__ == '__main__':
    res = Solution().threeSum([-1,0,1,2,-1,-4])
    print(f" = {res}")
    assert(res == [[-1,-1,2],[-1,0,1]])