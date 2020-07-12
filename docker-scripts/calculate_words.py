#/bin/python
import re
import collections

def main():
	f = open("/tmp/index.html", "r")
	content = f.read()
	content = re.sub(r"<[a-z].*?>", "", content)
	content = re.sub(r"</?[a-z].*?>", "", content)
	frequency = collections.Counter(content.split())
	print(frequency.most_common())

if __name__ == "__main__":
	main()



