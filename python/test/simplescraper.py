# Simple Text Scraper based on Selenium
"""Simple Text Scraper based on Selenium and scrolling."""

__author__: "Vivek Menon"

import time
from selenium import webdriver
from selenium import *
from selenium.webdriver.common.keys import Keys
import csv
from itertools import izip
import re
from collections import Counter


browser = webdriver.Chrome()

pagedowns = 100

no_of_pagedowns = pagedowns

## Site URL
# Set URL to the URL you want to scroll through.

URL = # www.example.com
browser.get(URL)
time.sleep(1)

elem = browser.find_element_by_tag_name("body")
elem.send_keys(Keys.ESCAPE)

while no_of_pagedowns:
    elem.send_keys(Keys.PAGE_DOWN)
    time.sleep(0.2)
    no_of_pagedowns-=1


# Set the DOM element you want to examine
Element = #Class Name ex: productName

post_elems = browser.find_elements_by_class_name("productName")

siteelements = []

for post in post_elems:
    title = 'Adidas ' + post.text
    print title
    sitelements.append(title)


# Results
# Filter for Unique Results

siteelements = filter( lambda s: not (len(s)==7), siteelements)


with open('siteelements.csv', 'w+') as f:
    writer = csv.writer(f)
    writer.writerows(izip(siteelements[1:300])
    f.close()
