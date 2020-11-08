struct Test {
    let rank: Int
}

var x = [Test(rank: 9), Test(rank: 4), Test(rank: 9), Test(rank: 1)]

x = x.sorted { (one: Test, two: Test) -> Bool in
    return one.rank < two.rank
}

x

let a = Test(rank: 9)
let b = Test(rank: 6)

a.rank == b.rank
