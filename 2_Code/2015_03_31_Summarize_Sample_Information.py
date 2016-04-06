import glob,re
import subprocess


Plates = ['/media/THING1/Illumina/120105_SN423_0229_BD0M9HACXX/Unaligned/Project_46335/', ## PLEASE
        '/media/THING1/Illumina/120523_SN423_0272_AD0WJRACXX/Unaligned/Project_50478/',
        '/media/THING1/Illumina/130607_SN423_0380_AC25E3ACXX/Unaligned/Project_58792/',
        '/media/THING1/Illumina/130207_SN431_0257_AC1DT9ACXX/Unaligned/Project_55952/',
        #'/media/THING1/Illumina/130207_SN431_0257_AC1DT9ACXX/Unaligned/Project_55952/' ## COMBO, already in the above path
        ]

ori_path = []
for pla in Plates:
	ori_path = ori_path + glob.glob(pla+'/*/*')

#print ori_path
#/media/THING1/Illumina/120105_SN423_0229_BD0M9HACXX/Unaligned/Project_46335/Sample_7001-03/7001-03_ATCACG_L008_R1_001.fastq.gz
file2path = {}
for op in ori_path:
	arr = op.split('/')
	sample_name = arr[-2]
	file_name = arr[-1]
	if re.search('fastqc',file_name) or re.search('SampleSheet',file_name):continue
	if re.search('^\d',file_name):
		file2path[file_name.split('.')[0]] = op.split('Sample_')[0]
#print file2path


##### Check my copy
my_copy = ['/media/THING2/eric/0_PLEASE_Fastq/',
          '/media/THING2/eric/1_COMBO_Kids_Shortgun_Sequencing_Fastq/']
my_path = []
for mc in my_copy:
	my_path = my_path + glob.glob(mc+'/*/*')
#print my_path

## I merged two repeated runs into one and changed the name 001 to 002
## /media/THING1/Illumina/120105_SN423_0229_BD0M9HACXX/Unaligned/Project_46335/
## 7003-04_GAGTGG_L008_R1_001.fastq.gz  -> 7003-04_GAGTGG_L008_R1_002.fastq.gz
## 7003-04_GAGTGG_L008_R2_001.fastq.gz  -> 7003-04_GAGTGG_L008_R2_002.fastq.gz
## /media/THING1/Illumina/120523_SN423_0272_AD0WJRACXX/Unaligned/Project_50478/
## 7003-04_GCCAAT_L001_R1_001.fastq.gz  -> 7003-04_GCCAAT_L001_R1_001.fastq.gz
## 7003-04_GCCAAT_L001_R2_001.fastq.gz  -> 7003-04_GCCAAT_L001_R2_001.fastq.gz


## These was some labeling error by people who collected the samples.
## The names of the following samples have been changed.
## Old: 6004-01,02,03
## New: 6004-01,03,04
## 02 -> 03, 03 -> 04
opt = open('../3_Result/2015_03_31_Raw_Data_Information.xls','w')
opt.write('SampleID\tFileName\tMyCopyPath\tOriginalPath\tMD5MyCopy\n')
for mp in my_path:
	if re.search('fastq.gz',mp):
		print mp
		print_line = []
		arr = mp.split('/') 
		sample_name = arr[-2]
		file_name = arr[-1]
		###
		md5 = subprocess.check_output("zcat %s | md5sum" % mp, shell=True).split(' ')[0]
		#print md5 
		##
		if re.search('7003-04_GAGTGG',file_name):
			print_line = [sample_name,file_name,mp,file2path[file_name.replace('002','001').split('.')[0]],md5 ]
		elif re.search('6004-03',file_name):
			print_line = [sample_name,file_name,mp,file2path[file_name.replace('6004-03','6004-02').split('.')[0]],md5 ]
		elif re.search('6004-04',file_name):
			print_line = [sample_name,file_name,mp,file2path[file_name.replace('6004-04','6004-03').split('.')[0]],md5 ]
		else:
			print_line = [sample_name,file_name,mp,file2path[file_name.split('.')[0]],md5 ]
		#print print_line
		opt.write(('%s\n') % ('\t').join(print_line))
		#break
opt.close()
	



