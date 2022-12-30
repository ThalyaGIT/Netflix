import pandas as pd
import requests
import urllib
import pandas as pd
from requests_html import HTML
from requests_html import HTMLSession
import requests
import bs4

# Defining Functions
def get_source(url):
    """Return the source code for the provided URL. 

    Args: 
        url (string): URL of the page to scrape.

    Returns:
        response (object): HTTP response object from requests_html. 
    """

    try:
        session = HTMLSession()
        response = session.get(url)
        return response

    except requests.exceptions.RequestException as e:
        print(e)

def get_googleInfo(title):

    scrapedData = []

    query = urllib.parse.quote_plus(title)
    response = get_source("https://www.google.co.uk/search?q=" + query)

    soup = bs4.BeautifulSoup(response.text,"html.parser")
                        
    rating_object=soup.find_all( "div", {"class":"a19vA"} )
    info_object=soup.find_all( "div", {"class":"rVusze"} )
    desc_object=soup.find_all( "div", {"class":"PZPZlf hb8SAc"} )

    scrapedData.append('Title: ' +title)

    for rating in rating_object:
        ratingInfo = rating.getText()
        rating = ratingInfo[0:3]
        scrapedData.append('Rating: ' +rating)

    for info in info_object:
        info = info.getText()
        if 'Language' in info:
            scrapedData.append(info)
            break
    
    for info in info_object:
        info = info.getText()
        if 'Genre' in info:
            scrapedData.append(info)
            break

    for desc in desc_object:
        description = desc.getText()
        description = description[0:11] + str(': ') + description[11:]
        scrapedData.append(description)
        break
    
    return scrapedData

# Test Function
get_googleInfo("Squid Game")

# Apply data scraping function on all movie/show titles in dataset and save info into new CSV
data = pd.read_csv('netflix_titles.csv')
goolgeInfo = data['title'].apply(get_googleInfo)
goolgeInfo.to_csv('googleInfo.csv', encoding='utf-8', index=False)