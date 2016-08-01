
Return your answers within 4 hours in an email with separate attachments (1 file per question) to admissions@galvanize.com with the email subject “Data Science Technical Assessment: Vivek Menon.”        

# Q1


The challenge is to create a text content analyzer. This is a tool used by writers to find statistics such as word and sentence count on essays or articles they are writing.
Write a Python program that analyzes input from a file and compiles statistics on it.
The program should output:
1. The total word count
2. The count of unique words
3. The number of sentences
Example output:

Total word count: 468
Unique words: 223
Sentences: 38

Brownie points will be awarded for the following extras:
1. The ability to calculate the average sentence length in words
2. The ability to find often used phrases (a phrase of 3 or more words used over 3 times)
3. A list of words used, in order of descending frequency
4. The ability to accept input from STDIN, or from a file specified on the command line.
This question should be written in Python. Please submit a file (q1.py) with your code.



```python
#!/usr/bin/env python

# Python Text Content Analyzer
# v 1.0
# Vivek Menon

# Requirements
# 1. The total word count [done]
# 2. The count of unique words [done]
# 3. The number of sentences [done]

# Bonus Points
# 1. The ability to calculate the average sentence length in words [done]
# 2. The ability to find often used phrases (a phrase of 3 or more words used over 3 times) [ntlk trigrams - TBD]
# 3. A list of words used, in order of descending frequency [done]
# 4. The ability to accept input from STDIN, or from a file specified on the command line. [done]

# Required modules
import sys
import re

# Pass in a text file as first argument
inFile = sys.argv[1]

# Open and read the text file
with open(inFile,'r') as i:
    text = i.readlines()

def TextContentAnalyzer(f):
    """
    A simple program that processes a a corpus, returns word count, unique word count, sentence count, average sentence length, and a list of all unique words in desending order.
    """

    # Variables
    words = []
    sentences = 0
    punctuation = []
    wordCount = {}
    sentenceLength = []

    # Match sentences by regex, split by punctuation, and count
    for line in f:
        sentences += len(re.split(r'[.!?]+', line.strip()))-1
        sentenceWords = line.split()
        sentenceLength.append(len(sentenceWords))

        words = words + sentenceWords
        for word in sentenceWords:
            if word in wordCount:
                wordCount[word] += 1
            else:
                wordCount[word] = 1


    # Return values as per Galvanize requirements

    print("Total Word Count: {}".format(len(words)))
    #print(wordsCount)
    print("Total Unique Word Count: {}".format(len(wordCount.keys())))
    #print(wordCount.keys())
    print("Total Number of Sentences: {}".format(sentences))
    print("Average Sentence Length: {}".format(sum(sentenceLength)/len(sentenceLength)))
    print("All Unique Words Used in Descending Order: {}".format(sorted(wordCount.items(), reverse=True, key=lambda item: item[1])))

TextContentAnalyzer(text)
```

# Q2

Suppose we have 2 tables called Orders and Salesperson shown below

![tables](SQLTables.png)

Write a SQL query that retrieves the names of all salespeople that have more than 1 order from the tables above. You can assume that each salesperson only has one ID.

Please submit a file q2.sql with your query.


```python
SELECT
    Salesperson.Name,
    Salesperson.ID,
    COUNT(Salesperson.ID) AS Sales
FROM
    Salesperson
        JOIN Orders
            ON Salesperson.ID=Orders.salesperson_id
GROUP BY 
    Salesperson.ID
ORDER BY
    Sales DESC;
```

# Q3 

#### Introduction
As context, here's a 10,000-foot view of the Acme Corp product:
* A consumer posts a request for a service needed. Every request is in some category (e.g., Catering, Personal Training, Interior Design) and some location (e.g., New York, San Francisco).
* We match the request up with appropriate service providers and send each of those providers an invite to quote on the request.
* Providers view the invite and some choose to send a quote to the consumer expressing interest.
For the following questions, please be as specific and thorough as possible in your answers, quantify your statements as much as you can, and explain your computations. Include code you used where appropriate. You're free to use any software you like; it's OK if we can't run the analysis ourselves. You're encouraged to be as technical as you like in your answers, they don't need to be accessible to general readers (though that's an important part of the actual job).

#### Split Test Analysis

I've just concluded a test of our quote form. After receiving an invite, service providers come to the quote form to view the consumer request and choose whether or not to pay to send a quote. My goal was to determine if certain changes to the design of the form would cause more providers to send a quote after coming to the page.
Over the course of a week, I divided invites from about 3000 requests among four new variations of the quote form as well as the baseline form we've been using for the last year. Here are my results:        

* Baseline: 32 quotes out of 595 viewers
* Variation 1: 30 quotes out of 599 viewers
* Variation 2: 18 quotes out of 622 viewers
* Variation 3: 51 quotes out of 606 viewers
* Variation 4: 38 quotes out of 578 viewers

What's your interpretation of these results? What conclusions would you draw? What questions would you ask me about my goals and methodology? Do you have any thoughts on the experimental design? Please provide statistical justification for your conclusions and explain the choices you made in your analysis.

For the sake of your analysis, you can make whatever assumptions are necessary to make the experiment valid, so long as you state them. So, for example, your response might follow the form "I would ask you A, B and C about your goals and methodology. Assuming the answers are X, Y and Z, then here's my analysis of the results... If I were to run it again, I would consider changing...".

Here are the data in CSV form, if that's more convenient:

Bucket,Quotes,Views
Baseline,32,595
Variation 1,30,599
Variation 2,18,622
Variation 3,51,606
Variation 4,38,578

Please submit a text, markdown or pdf file with your analysis.


```python
# Autosave every 60 seconds
%autosave 60

# Plot inline
%matplotlib inline
```



    Autosaving every 60 seconds



```python
# Modules
import pandas
import numpy
from ggplot import *
```


```python
q3 = pandas.read_csv('q3.csv')
```


```python
q3
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Bucket</th>
      <th>Quotes</th>
      <th>Views</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Baseline</td>
      <td>32</td>
      <td>595</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Variation 1</td>
      <td>30</td>
      <td>599</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Variation 2</td>
      <td>18</td>
      <td>622</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Variation 3</td>
      <td>51</td>
      <td>606</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Variation 4</td>
      <td>38</td>
      <td>578</td>
    </tr>
  </tbody>
</table>
</div>




```python
q3['ConversionRates'] = (q3.Quotes/q3.Views) * 100
q3['ConversionDifference'] = (q3.ConversionRates - q3.ConversionRates[0])
```


```python
for i in range(1,len(q3)):
    print("{} had a conversion rate of {}%, which beat the baseline by {}%".format(q3.Bucket[i],round(q3.ConversionRates[i]), round(q3.ConversionDifference[i])))
```

    Variation 1 had a conversion rate of 5.0%, which beat the baseline by -0.0%
    Variation 2 had a conversion rate of 3.0%, which beat the baseline by -2.0%
    Variation 3 had a conversion rate of 8.0%, which beat the baseline by 3.0%
    Variation 4 had a conversion rate of 7.0%, which beat the baseline by 1.0%



```python
q3 = q3.sort_values('ConversionRates', ascending=False)
```


```python
q3
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Bucket</th>
      <th>Quotes</th>
      <th>Views</th>
      <th>ConversionRates</th>
      <th>ConversionDifference</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>3</th>
      <td>Variation 3</td>
      <td>51</td>
      <td>606</td>
      <td>8.415842</td>
      <td>3.037690</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Variation 4</td>
      <td>38</td>
      <td>578</td>
      <td>6.574394</td>
      <td>1.196243</td>
    </tr>
    <tr>
      <th>0</th>
      <td>Baseline</td>
      <td>32</td>
      <td>595</td>
      <td>5.378151</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Variation 1</td>
      <td>30</td>
      <td>599</td>
      <td>5.008347</td>
      <td>-0.369804</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Variation 2</td>
      <td>18</td>
      <td>622</td>
      <td>2.893891</td>
      <td>-2.484261</td>
    </tr>
  </tbody>
</table>
</div>




```python
plot = ggplot(q3, aes(x='Bucket', weight='Quotes'))
plot + geom_bar()
```


![png](output_19_0.png)





    <ggplot: (288487323)>



### Conclusions

### Overall: 

The goal was to find which quote form yielded **the highest conversion rate** with regard to quotes recieved per service provider view.

Based on testing, that variation was **Variation 3**, which had an **overall conversion rate of 8.41%, beating the baseline by 3.03%**. The second bast was Variation 4, and the worst performers were Variation 1 nad 2, which performed below the baseline. 

### Questions

#### Statistical
* Are these 3000 samples i.i.d.? 
* What percent of the population is this sample?
* What is the standard error of this sample?
* Do we have a large enough sample to be statistically representative? Could we get better p-values?
* Why do the variations have different numbers of viewers? What is the effect size?
* How was a particular variation chosen? Was it divided up randomly? 

#### General
* Different categories seem like they should have different numbers of fields, different parameters, and different quote respone times (Catering vs. Personal Training); how did you account for all that variation? 
* Did you account for the fact that some categories/request types were necessarily more responsive than others? (i.e. Catering vs Interior Design) 
* Did form changes apply to all quote forms across all categories?
* How did you control for date and time? 
* Why is the goal to get more quotes; isn't the goal to get more requests? 
* How did you account for the users who send quotes to every request, regardless of form type?
* How standardized are the quotes?
* What about situations where the form was failed to be completed? 
* If you refresh the view, do you just get the old form, or another random variation? 

### Future Changes

1. Go for 10,000 requests, since a larger sample is generally more valid.
2. Divide those 10,000 requests evenly across all categories, and label them as such (10% Catering, 10% Personal Training, etc.) 
3. Randomly alter the quote forms for requests in those categories until the buckets are filled (1000 Catering Quote forms, etc.)
4. Include more information about the Quote Forms as possible, like the following example fields:
    * Time to complete form
    * Number or fields interacted with
    * Form field order
    * etc.
5. Collect data and run statistical tests to ensure validity, namely:
    * Standard deviation
    * Volatility
    * Standard Error
    * P-values
    * etc. 
6. Analyze Conversion Rate by Category and Aggregate, in order to find which Quote modifications work best in which category.
7. Retest with new variations consistently; Replace 1 and 2 with new options, keep Baseline consistent, and optimize over time.
8. After a defined period of truly random testing (maybe 1 month), decide on a new lead variation and implement into production. 
