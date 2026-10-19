import json,pathlib,subprocess,tempfile
root=pathlib.Path(__file__).resolve().parents[1]
binary=root/'.build/sovereign_router'
with tempfile.TemporaryDirectory() as tmp:
    ledger=pathlib.Path(tmp)/'ledger.jsonl'
    inputs=[0,1,9959,2**31-1]
    for value in inputs:
        p=subprocess.run([str(binary),str(value),str(ledger)],capture_output=True,text=True,check=True)
        record=json.loads(p.stdout)
        assert int(record['trace'])==2*value and record['budget']==value
    lines=ledger.read_text().splitlines()
    assert len(lines)==len(inputs)
    for value,line in zip(inputs,lines):assert int(json.loads(line)['trace'])==value*2
    for bad in ['-1','2147483648','4294967295','hello','1x','']:
        p=subprocess.run([str(binary),bad],capture_output=True,text=True)
        assert p.returncode!=0,(bad,p.stdout)
print('Objective-C -> generated OCaml: exact traces, ledger writes and input rejection passed.')
