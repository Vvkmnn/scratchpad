# A soundcloud player to prank my friend
"""Lol."""

from selenium import webdriver
import random
import time

def Player(URL, loops, mintime, maxtime):
    # Load a Chrome Browser and go to the URL
    print('Loading browser...')
    browser = webdriver.Chrome()
    browser.get(URL)
    time.sleep(5)
    title = browser.title
    print('Beginning loops for %s:' % (title))
    play = []
    for loop in range(1, loops):
        try:
            playCounter = browser.find_element_by_css_selector('#content > div > div.l-listen-wrapper > div.l-about-main > div > div:nth-child(1) > div > div > div.listenEngagement__footer.sc-clearfix > div.listenEngagement__extras > div > ul')
            play.append(playCounter.text[0:3])
            print("Current play count is %s." %(play[-1]))
        except:
            continue
        # Wait
        time.sleep(random.randrange(mintime, maxtime, 1))
        # Refresh/quit browser instance
        browser.refresh()
        # Metrics
        print("This is loop number %s." %(loop))
    print('Loops for %s have increased by %d.' %(title, loops-1))
    print('Plays for %s have increased by %d.' %(title, int(play[-1])-int(play[0])))
    #End Session
    browser.quit()

Player("https://soundcloud.com/itsekke/glory-in-the-highest-prod-ryan-little", 300, 5, 10)
