#!/usr/bin/env python3
"""
Compares output of probability plugin with probabilities calculated independently
from the source data (meps_conditions_source.grib) with numpy.

Usage: check_conditions.py <source.grib> <output name>=<spec> ...
Specs are listed in OUTPUTS below.
"""

import glob
import sys
import numpy as np
import eccodes as ec

ALLOW_MISSING = {"PRECFORM2-N"}
PARAMS = {19: "PRECFORM2-N", 52: "RRR-KGM2"}

ops = {
    ">": lambda a, v: a > v[0],
    "=": lambda a, v: a == v[0],
    "=[]": lambda a, v: np.isin(a, v),
}

PRIMARY_RRR = ("RRR-KGM2", ">", [0.04])
COND_PTYPE_1 = ("PRECFORM2-N", "=", [1.0])

# output name -> list of rules that must all be true
OUTPUTS = {
    "PROB-RR1-1": [PRIMARY_RRR, COND_PTYPE_1],
    "PROB-RR-4": [COND_PTYPE_1, PRIMARY_RRR],
    "PROB-RR-7": [PRIMARY_RRR],
    "PROB-RR3-6": [PRIMARY_RRR],
    "PROB-FRRAIN": [PRIMARY_RRR, ("PRECFORM2-N", "=[]", [4.0, 5.0])],
}


def read(fname):
    data = {}
    with open(fname, "rb") as f:
        while True:
            h = ec.codes_grib_new_from_file(f)
            if h is None:
                break
            ec.codes_set(h, "missingValue", 9999.0)
            name = PARAMS[ec.codes_get(h, "parameterNumber")]
            v = ec.codes_get_values(h).astype(np.float32)
            v[v == 9999.0] = np.nan
            data.setdefault(name, []).append(v)
            ec.codes_release(h)
    return {k: np.array(v) for k, v in data.items()}


def expected(data, rules):
    nmembers = next(iter(data.values())).shape[0]
    valid = np.ones(data["PRECFORM2-N"].shape, dtype=bool)
    match = np.ones(data["PRECFORM2-N"].shape, dtype=bool)
    for name, op, value in rules:
        a = data[name]
        if name not in ALLOW_MISSING:
            valid &= ~np.isnan(a)
        match &= ops[op](a, np.float32(value))
    cnt = np.sum(match & valid, axis=0).astype(np.float64)
    den = np.sum(valid, axis=0)
    with np.errstate(invalid="ignore", divide="ignore"):
        p = np.where(den > 0, cnt / den, np.nan)
    return p.astype(np.float32)


def main():
    data = read(sys.argv[1])
    failed = False
    for name, rules in OUTPUTS.items():
        files = glob.glob("{}_*.grib2".format(name))
        if len(files) != 1:
            print("{}: expected exactly one output file, got {}".format(name, files))
            failed = True
            continue
        got = read_flat(files[0])
        exp = expected(data, rules)
        if not np.allclose(got, exp, atol=1e-5, equal_nan=True):
            idx = np.where(~np.isclose(got, exp, atol=1e-5, equal_nan=True))[0][:10]
            print("{}: mismatch at points {}: got {} expected {}".format(name, idx, got[idx], exp[idx]))
            failed = True
        else:
            print("{}: ok".format(name))
    sys.exit(1 if failed else 0)


def read_flat(fname):
    with open(fname, "rb") as f:
        h = ec.codes_grib_new_from_file(f)
        ec.codes_set(h, "missingValue", 9999.0)
        v = ec.codes_get_values(h).astype(np.float32)
        v[v == 9999.0] = np.nan
        ec.codes_release(h)
    return v


if __name__ == "__main__":
    main()
