// SPDX-License-Identifier: GPL-3.0-only

// The results of evaluating the fair win function are independent from environment-dependent state 

rule winner_computation_env_independent() {
    env e1;
    env e2;

    address p0;
    address p1;

    string s0;
    string s1;

    address w1 = computeWinner(e1, p0, p1, s0, s1);
    address w2 = computeWinner(e2, p0, p1, s0, s1);

    assert w1 == w2;
}