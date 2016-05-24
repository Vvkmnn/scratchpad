# A soundcloud player to prank my friend
"""Lol."""

from selenium import webdriver
import random
import time

URL = "https://soundcloud.com/itsekke/glory-in-the-highest-prod-ryan-little"


def Player(URL):
    # Load a Chrome Browser and go to the URL
    browser = webdriver.Chrome()
    browser.get(URL)
    for loop in range(1, 100):
        # Get play count
        playCounter = browser.find_element_by_css_selector('#content > div > div.l-listen-wrapper > div.l-about-main > div > div:nth-child(1) > div > div > div.listenEngagement__footer.sc-clearfix > div.listenEngagement__extras > div > ul > li:nth-child(1) > span > span:nth-child(2)')
        play = playCounter.text
        # Wait
        time.sleep(random.randrange(30, 15, 1))
        # Quit the browser instance
        browser.refresh()
        # Metrics
        print("This is loop number %s." %(loop))
        print("Current play count is %s." %(play))

Player(URL)
 
