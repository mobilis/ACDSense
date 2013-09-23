import rdflib, sys, getopt, os, string
import xml.etree.cElementTree as ET

from rdflib import plugin
from os import listdir
from os.path import isfile, join

plugin.register(
	'sparql', rdflib.query.Processor,
	'rdfextras.sparql.processor', 'Processor')
plugin.register(
	'sparql', rdflib.query.Result,
	'rdfextras.sparql.query', 'SPARQLQueryResult')
	
def get_string_components(observation_string,separator):
	return string.split(observation_string,separator)

def get_timestamp_element_from_components(components):
	timestamp_element = ET.Element("timestamp")
	
	year_element = ET.SubElement(timestamp_element,"year")
	month_element = ET.SubElement(timestamp_element,"month")
	day_element = ET.SubElement(timestamp_element,"day")
	hour_element = ET.SubElement(timestamp_element,"hour")
	minute_element = ET.SubElement(timestamp_element,"minute")
	second_element = ET.SubElement(timestamp_element,"second")
	
	year_element.text = components[3].zfill(2)
	month_element.text = components[4].zfill(2)
	day_element.text = components[5].zfill(2)
	hour_element.text = components[6].zfill(2)
	minute_element.text = components[7].zfill(2)
	second_element.text = components[8].zfill(2)

	return timestamp_element

def write_result_to_file(result):
	root = ET.Element("sensorItem")
	
	first = 1
	file_exists = 1
	file_name = ""
	for row in result:
		if row.observation is None:
			return;
		components = get_string_components(row.observation,'_')
		file_name = components[2] + ".xml"
		try:
			with open(file_name):
				tree = ET.parse(file_name);
				root = tree.getroot()
		except IOError:
			file_exists = 0
		if first == 1 and file_exists == 0:
			sensorID = ET.SubElement(root,"sensorId")
			sensorID.text = components[2]
			first = 0
		values = ET.Element("values")
		value = ET.Element("value")
		value.text = row.value
		sensorValueType = ET.Element("subType")
        sensorValueType.text = components[1]
        unit = ET.Element("unit")
        timestamp = get_timestamp_element_from_components(components)
        values.append(value)
        values.append(sensorValueType)
        values.append(timestamp)
        try:
        	unit.text = row.unit[row.unit.index('#') + 1:]
        except ValueError:
        	unit.text = ""
        values.append(unit)
        root.append(values)
	
	tree = ET.ElementTree(root)
	tree.write(file_name)

def files_in_directory(directory):
	return [f for f in listdir(directory) if isfile(join(directory,f))]

def parse(file):
	g = rdflib.Graph()
	g.parse(file, format="n3")
	return g
	
def query(graph, query_file):
	file = open(query_file,"r")
	sparql_content = file.read()
	file.close()
	
	result = graph.query(sparql_content)
	write_result_to_file(result)

def main(argv):
	try:
		opts, args = getopt.getopt(argv, "md:", [])
	except getopt.GetoptError:
		usage()
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("m"):
			print "m"
		else:
			datafiles = files_in_directory(arg)
			print "Total Number of Files: {}" .format(len(datafiles))
			counter = 0
			for file in datafiles:
				counter += 1
				print "Parsing {} of {} files".format(counter,len(datafiles))
				query(parse(arg + '/' + file), "sparql.txt")
	
if __name__ == '__main__':
	main(sys.argv[1:])