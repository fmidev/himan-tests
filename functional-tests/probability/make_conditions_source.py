#!/usr/bin/env python3
"""
Generates meps_conditions_source.grib: synthetic 10-member MEPS-like ensemble containing
PRECFORM2-N (ptype) and RRR-KGM2 (total precipitation rate). Each of the first grid points is
built to exercise one rule of the probability plugin 'conditions' array. All other grid points have
ptype=0 and rrr=0 in every member.

Grid, time and ensemble metadata are copied from meps_preform_source.grib so that the same
database definitions (producer 260, MEPSSCAN2500) apply.

Usage: ./make_conditions_source.py
"""

import numpy as np
import eccodes as ec

TEMPLATE = "meps_preform_source.grib"
OUTPUT = "meps_conditions_source.grib"
NMEMBERS = 10
MISSING = np.nan

# Per test point: (ptype values for the 10 members, rrr values for the 10 members)
# Use None for a missing value.
CASES = []


def case(ptype, rrr):
    CASES.append((ptype, rrr))


def rep(v, n):
    return [v] * n


# 0: all members satisfy both conditions                   -> joint 1.0
case(rep(1, 10), rep(0.10, 10))
# 1: no member satisfies                                    -> 0.0
case(rep(0, 10), rep(0.0, 10))
# 2: partial: m0-2 both, m3-5 ptype only, m6-8 rrr only, m9 none
#    joint=0.3 (ptype alone 0.6, rrr alone 0.6, product 0.36)
case([1, 1, 1, 1, 1, 1, 0, 0, 0, 0], [0.10, 0.10, 0.10, 0.01, 0.01, 0.01, 0.10, 0.10, 0.10, 0.0])
# 3: boundary: rrr exactly 0.04 must not count with '>'    -> 0.5
case(rep(1, 10), rep(0.04, 5) + rep(0.05, 5))
# 4: ptype missing in m0-1 (allow-missing param): counts as no match, stays in denominator -> 0.8
case([None, None] + rep(1, 8), rep(0.10, 10))
# 5: rrr missing in m0-1: members dropped from denominator -> 8/8 = 1.0
case(rep(1, 10), [None, None] + rep(0.10, 8))
# 6: rrr missing in all members                             -> output missing
case(rep(1, 10), rep(None, 10))
# 7: rain forms for the '=[]' condition (4,5) with rrr > 0.04 everywhere
case([4, 5, 4, 5, 0, 1, 2, 3, 4, 5], rep(0.10, 10))
# 8: ptype missing in all members (allow-missing param)     -> 0.0
case(rep(None, 10), rep(0.10, 10))


def fill(values_per_member, member, ncases, ngrid, outside):
    """Return flat array of ngrid with test points filled for given member"""
    arr = np.full(ngrid, outside, dtype=np.float64)
    for i in range(ncases):
        v = values_per_member[i][member]
        arr[i] = MISSING if v is None else v
    return arr


def main():
    with open(TEMPLATE, "rb") as f:
        templates = []
        while True:
            h = ec.codes_grib_new_from_file(f)
            if h is None:
                break
            templates.append(h)

    assert len(templates) == NMEMBERS

    ncases = len(CASES)
    ptype_cases = [c[0] for c in CASES]
    rrr_cases = [c[1] for c in CASES]

    with open(OUTPUT, "wb") as out:
        for m, t in enumerate(templates):
            ngrid = ec.codes_get(t, "Ni") * ec.codes_get(t, "Nj")

            # ptype: copy template, replace values. Bitmap is kept as-is, ie. all points are
            # defined; missing values are represented with nan -> bitmap
            h = ec.codes_clone(t)
            ec.codes_set(h, "bitmapPresent", 1)
            ec.codes_set(h, "missingValue", 9999.0)
            v = fill(ptype_cases, m, ncases, ngrid, 0.0)
            v[np.isnan(v)] = 9999.0
            ec.codes_set(h, "packingType", "grid_ccsds")
            ec.codes_set(h, "bitsPerValue", 8)
            ec.codes_set_values(h, v)
            ec.codes_write(h, out)
            ec.codes_release(h)

            # rrr: clone ptype message and turn it to total precipitation rate of past hour.
            # PDT 11 (individual ensemble forecast, statistical processing over time range)
            h = ec.codes_clone(t)
            ec.codes_set(h, "productDefinitionTemplateNumber", 11)
            ec.codes_set(h, "parameterCategory", 1)
            ec.codes_set(h, "parameterNumber", 52)
            ec.codes_set(h, "typeOfStatisticalProcessing", 1)
            ec.codes_set(h, "lengthOfTimeRange", 1)
            ec.codes_set(h, "indicatorOfUnitForTimeRange", 1)
            ec.codes_set(h, "endStep", 48)
            ec.codes_set(h, "startStep", 47)
            ec.codes_set(h, "perturbationNumber", m)
            ec.codes_set(h, "numberOfForecastsInEnsemble", NMEMBERS)
            ec.codes_set(h, "bitmapPresent", 1)
            ec.codes_set(h, "missingValue", 9999.0)
            v = fill(rrr_cases, m, ncases, ngrid, 0.0)
            v[np.isnan(v)] = 9999.0
            # decimal scaling so that values like 0.04 are exactly representable as float32
            ec.codes_set(h, "packingType", "grid_ccsds")
            ec.codes_set(h, "decimalScaleFactor", 2)
            ec.codes_set(h, "bitsPerValue", 16)
            ec.codes_set_values(h, v)
            ec.codes_write(h, out)
            ec.codes_release(h)

    for t in templates:
        ec.codes_release(t)

    # verify that values survive packing
    with open(OUTPUT, "rb") as f:
        while True:
            h = ec.codes_grib_new_from_file(f)
            if h is None:
                break
            if ec.codes_get(h, "parameterNumber") == 52:
                vals = ec.codes_get_values(h).astype(np.float32)
                ec.codes_set(h, "missingValue", 9999.0)
                for i in range(ncases):
                    exp = rrr_cases[i][ec.codes_get(h, "perturbationNumber")]
                    if exp is not None and exp > 0:
                        assert vals[i] == np.float32(exp), (i, vals[i], exp)
            ec.codes_release(h)

    print("wrote", OUTPUT)


if __name__ == "__main__":
    main()
