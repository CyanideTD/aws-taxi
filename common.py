import boto3

def fetal(message):
    sys.stderr.write("fetal: %s\n" % message)
    sys.stderr.flush()
    sys.stderr.exit(1)

def error(message):
    sys.stderr.write("error: %s\n" % message)
    sys.stderr.flush()
    sys.stderr.exit(1)

def file_name(color, year, month):
    return "%s-%s%02d.csv" % (color, year, int(month))

def file_size(source, file_name):
    if source.startwith('s3://'):
        s3 = boto3.resource('s3')
	bucket = s3.Bucket(source[5:])
	try:
	    s3.meta.client.head_bucket(Bucket=bucket.name)
	except botocore.exception.ClientError as e:
	    error_code = int(e.response['Error']['Code'])
	    if error_code = 404:
		fetal("%s does not existis" % file_name)
    
    return bucket.Object(file_name).content_length

class Options:
    def __init__(self):
	self.parser = argparse.ArgumentParser(
            formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	
	self.parser.add_argument(
            "-c", "--color", type=str, default='yellow', help="color of taxi")

	self.parser.add_argument(
            "-y", "--year", type=int, default=2016, help="year of record")
	
	self.parser.add_argument(
	    "-m", "--month", type=int, default=1, help="month of record")
	
	self.parser.add_argument(
	    "--config", type=str, default='config.ini', help="configuration plan")

	
