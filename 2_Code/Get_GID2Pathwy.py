

##### Load ID to name
ID2Name = {}
inputfile = '/media/THING2/rohinis/please_humann/humann-0.99/data/pathwayc'
opin = file(inputfile,'r')
opt = file('GID2Pathway.txt','w')
for Line in opin:
    Line = Line.rstrip()
    Array = Line.split('\t')
    Path  = Array[0]
    GIDs  = Array[1:]
    for GID in GIDs:
        opt.write('%s\t%s\n' % (Path,GID))
opin.close()
opt.close()

