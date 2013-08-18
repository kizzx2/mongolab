var targetDB = db.foos;
// var targetDB = db.rnd_foos;

function sequentialInsert(n) {
  for(var i = 0; i < n; i++) {
    db.foos.insert({ t: "2013-06-23", n: 7 * i, a: 1, v: 0, j: "1234" });
  }
  db.getLastError();
}

function batchInsert(n) {
  var docs = [];

  for(var i = 0; i < n; i++) {
    docs.push({ t: "2013-06-23", n: 7 * i, a: 1, v: 0, j: "1234" });
  }

  db.foos.insert(docs);
  db.getLastError();
}

function sequentialInsertRnd(n) {
  for(var i = 0; i < n; i++) {
    db.rnd_foos.insert({ rnd: _rand(), t: "2013-06-23", n: 7 * i, a: 1, v: 0, j: "1234" });
  }
  db.getLastError();
}

function batchInsertRnd(n) {
  var docs = [];

  for(var i = 0; i < n; i++) {
    docs.push({ rnd: _rand(), t: "2013-06-23", n: 7 * i, a: 1, v: 0, j: "1234" });
  }
  docs.sort(function(a, b) { return a.rnd - b.rnd; });

  db.rnd_foos.insert(docs);
  db.getLastError();
}

var count0 = targetDB.find().count();
var t0 = Date.now();

// sequentialInsert(20000);
batchInsert(20000);
// sequentialInsertRnd(20000);
// batchInsertRnd(20000);

var t1 = Date.now();
var count1 = targetDB.find().count();

var took = t1 - t0;
var count = count1 - count0;
var throughput = count / took * 1000;

print(count + " documents inserted");
print("Took " + took + "ms");
print(throughput + " doc/s");
