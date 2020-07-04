let a = [1, 2, 3]


func foo (a: [Int]) {
    var b = a
    b.remove(at: 0)
    print(b)
    print(a)
}

foo(a: a)
