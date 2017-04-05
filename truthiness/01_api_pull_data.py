import json
import urllib2
import pandas as pd
import re
import pdb
import argparse


def pull_truthiness(n_size)

	cols = ['date','name',
		'ruling','statement_text','party','url','subject']

	results = pd.DataFrame(columns=cols)

	f =urllib2.urlopen('http://www.politifact.com/api/statements/truth-o-meter/json/?n=10')

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

		data.loc[1] = [date,name,ruling,statement_text,party,url,subject]

		results = results.append(data)

	results['true_false'] = results['ruling']
	recode = {'Half-True': 'Half-True', 'Mostly True': 'True', 'True': 'True', 'Mostly False': 'False','False':'False'}
	results['true_false'] = results['true_false'].apply(str).map(recode)

	results['true'] = results['true_false']
	recode = {'True':1,'False':0,'Half-True':0}	
	results['true'] = results['true'].apply(str).map(recode)

	##Replace with db_upload
	results.to_csv("C:\\users\\augus\\desktop\\truthiness\\raw_truthiness.csv",index=False)

def estimate_truthiness()

	##Replace with db_download
	results = pd.read_csv('C:\\users\\augus\\desktop\\truthiness\\raw_truthiness.csv')

	results['pd_date'] = pd.to_datetime(results['date'])

	results['total_statements'] = results.groupby('name').cumcount(ascending=False) + 1

	results['total_true'] = results.groupby('name')['true'].cumsum()

	results['pct_true'] = results['total_true'] / results['total_statements']

#################

def truthiness_cmd():
    '''
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
