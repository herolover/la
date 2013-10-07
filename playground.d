import matrix : Mat33d, Vec3d;
import std.stdio;

// This doesn't belong to the library, but I'll just keep it for now.

void main()
{
    auto a = Mat33d([[2, 0, -3],
                     [0, 1, -1],
                     [0, 0,  1]]);
    auto b = Vec3d([5, 4, 1]);

    auto c = a * b;
    writeln(c);
}
