/*
Copyright 2013 Alexandr Kalenuk.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// TODO assertions for all invariants

module matrix;

import std.traits : isNumeric;

struct Matrix(T, int rows, int cols) {
    T[rows * cols] v;

    this(ref Matrix!(T, rows, cols) A) {
        foreach (i; 0 .. v.length) {
            v[i] = A.v[i];
        }
    }

    this(T[rows][cols] A) {
        foreach (i; 0 .. rows) {
            foreach (j; 0 .. cols) {
                v[j * rows + i] = A[i][j];
            }
        }
    }

    this(T[rows * cols] A) {
        foreach (i; 0 .. v.length) {
            v[i] = A[i];
        }
    }

    Matrix!(T, rows, cols) opUnary(string op)() if (op == "+" || op == "-") {
        auto res = Matrix!(T, rows, cols)();

        foreach (i; 0 .. v.length) {
            res.v[i] = mixin(op~"v[i]");
        }

        return res;
    }

    Matrix!(T, rows, cols) opBinary(string op)(ref Matrix!(T, rows, cols) A) if (op == "+" || op == "-") {
        auto res = Matrix!(T, rows, cols)();

        foreach (i; 0 .. v.length) {
            res.v[i] = mixin("v[i] "~op~" A.v[i]");
        }

        return res;
    }

    Matrix!(T, rows, cols) opOpAssign(string op)(ref Matrix!(T, rows, cols) A) if (op == "+" || op == "-") {
        this = opBinary!op(A);

        return this;
    }

    // Multiplication of matrix by matrix or matrix by vector
    Matrix!(T, rows, A_cols) opBinary(string op, int A_cols)(ref Matrix!(T, cols, A_cols) A) if (op == "*") {
        auto res = Matrix!(T, rows, A_cols)();

        foreach (i; 0 .. rows) {
            foreach (j; 0 .. A_cols) {
                res.v[j * rows + i] = 0;
                foreach (k; 0 .. cols) {
                    res.v[j * rows + i] += v[k * rows + i] * A.v[j * cols + k];
                }
            }
        }

        return res;
    }

    Matrix!(T, rows, cols) opBinary(string op, S)(S s) if ((op == "+" || op == "-" || op == "*" || op == "/") && isNumeric!S) {
        auto res = Matrix!(T, rows, cols)();

        foreach (i; 0 .. v.length) {
            res.v[i] = mixin("v[i] "~op~" s");
        }

        return res;
    }

    Matrix!(T, rows, cols) opOpAssign(string op, S)(S s) if ((op == "+" || op == "-" || op == "*" || op == "/") && isNumeric!S) {
        this = opBinary!op(A);

        return this;
    }
}

alias Matrix!(double, 2, 2) Mat22d;
alias Matrix!(double, 3, 3) Mat33d;
alias Matrix!(double, 3, 4) Mat34d;
alias Matrix!(double, 4, 4) Mat44d;
alias Matrix!(double, 2, 1) Vec2d;
alias Matrix!(double, 3, 1) Vec3d;
alias Matrix!(double, 4, 1) Vec4d;

unittest {
    auto a = Mat33d([[1, 2, 3],
                     [4, 5, 6],
                     [7, 8, 9]]);
    auto b = Vec3d([1, 2, 3]);

    assert((a * b).v == [14, 32, 50]);
    assert((a * a).v == [30, 66, 102, 36, 81, 126, 42, 96, 150]);
    assert((a + a).v == [2, 8, 14, 4, 10, 16, 6, 12, 18]);
    assert((a * 2).v == [2, 8, 14, 4, 10, 16, 6, 12, 18]);
    assert((a / 2).v == [0.5, 2, 3.5, 1, 2.5, 4, 1.5, 3, 4.5]);
    assert((a + 10).v == [11, 14, 17, 12, 15, 18, 13, 16, 19]);

    a += a;
    assert(a.v == [2, 8, 14, 4, 10, 16, 6, 12, 18]);

    a -= a;
    assert(a.v == [0, 0, 0, 0, 0, 0, 0, 0, 0]);
}
