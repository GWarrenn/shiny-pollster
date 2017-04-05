import json
import urllib2
import pandas as pd
import re
import pdb
import argparse


def pull_truthiness(n_size):

	cols = ['date','name',
		'ruling','party','url','subject','statement_text']

	results = pd.DataFrame(columns=cols)

	f =urllib2.urlopen('http://www.politifact.com/api/statements/truth-o-meter/json/?n='+n_size)

	data = json.load(f)

	for d in data:

		first_name = d['speaker']['first_name']
		last_name = d['speaker']['last_name']
		name = first_name+" "+last_name
		date = d['statement_date']
		ruling = d['ruling']['ruling']
		statement_text = d['statement']

		statement_text = re.sub(r"<p>", "", statement_text)
		statement_text = re.sub(r"</p>", "", statement_text)

		statement_text = re.sub(r"&quot;", "", statement_text)
		statement_text = re.sub(r"&#39;", "", statement_text)
		statement_text = re.sub(r"&rsquo;", "", statement_text)

		subjects = d['subject']
		sub = [li['subject'] for li in subjects]
		subject = ''
		for i in sub:
			subject = i+" ; "+subject

		party = d['speaker']['party']['party']
		url = d['statement_url']

		data = pd.DataFrame(columns=cols)		

		data.loc[1] = [date,name,ruling,party,url,subject,statement_text]

		results = results.append(data)

	results['true_false'] = results['ruling']
	recode = {'Half-True': 'Half-True', 'Mostly True': 'True', 'True': 'True', 'Mostly False': 'False','False':'False','Pants on Fire!':'False'}
	results['true_false'] = results['true_false'].apply(str).map(recode)

	results['true'] = results['true_false']
	recode = {'True':1,'False':0,'Half-True':0}	
	results['true'] = results['true'].apply(str).map(recode)

	results['false'] = results['true_false']
	recode = {'True':0,'False':1,'Half-True':0}	
	results['false'] = results['false'].apply(str).map(recode)

	results['half_truth'] = results['true_false']
	recode = {'True':0,'False':0,'Half-True':1}	
	results['half_truth'] = results['half_truth'].apply(str).map(recode)

	results['pants_on_fire'] = results['ruling']
	recode = {'Half-True': 0, 'Mostly True': 0, 'True': 0, 'Mostly False': 0,'False':0,'Pants on Fire!':1}
	results['pants_on_fire'] = results['pants_on_fire'].apply(str).map(recode)


	results['statement_text'] =  results.statement_text.str.replace('[^\x00-\x7F]','')
	results['subject'] =  results.subject.str.replace('[^\x00-\x7F]','')
	results['name'] =  results.name.str.replace('[^\x00-\x7F]','')


	##Replace with db_upload
	results.to_csv("C:\\users\\augus\\desktop\\truthiness\\raw_truthiness.csv",index=False)

def estimate_truthiness():

	##Replace with db_download
	results = pd.read_csv('C:\\users\\augus\\desktop\\truthiness\\raw_truthiness.csv')

	results['pd_date'] = pd.to_datetime(results['date'])

	results['total_statements'] = results.groupby('name').cumcount(ascending=False) + 1

	results = results.sort_values(by=['date'],ascending=True)

	##Running total & pct of true statements

	results['total_true'] = results.groupby('name')['true'].cumsum()
	results['pct_true'] = results['total_true'] / results['total_statements']

	##Running total & pct of false statements

	results['total_false'] = results.groupby('name')['false'].cumsum()
	results['pct_false'] = results['total_false'] / results['total_statements']

	##Running total & pct of 'half-true' statements

	results['total_half_truth'] = results.groupby('name')['half_truth'].cumsum()
	results['pct_half_truth'] = results['total_half_truth'] / results['total_statements']

	##Pants on Fire!
	results['total_pants_on_fire'] = results.groupby('name')['pants_on_fire'].cumsum()
	results['pct_pants_on_fire'] = results['total_pants_on_fire'] / results['total_statements']

	results = results.sort_values(by=['date'],ascending=False)

	try:
		results.to_csv("C:\\users\\augus\\desktop\\truthiness\\clean_truthiness.csv",index=False)
	except Exception as ex:
		print str(ex)

#################

def truthiness_cmd():
    '''placeholder for doc strings
    '''
    # set up the parser/argument information with command line help
    parser= argparse.ArgumentParser(description="Find out the truth...or how little it's told")
    parser.add_argument('n_size', help="Total amount of statements to pull")

    args=parser.parse_args()

    pull_truthiness(args.n_size)

    estimate_truthiness()

#################

def main():
    truthiness_cmd()

#################

if __name__=="__main__":
    main()

#################
