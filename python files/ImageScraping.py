
import pandas as pd
import requests
import urllib
from requests_html import HTML
from requests_html import HTMLSession
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

def get_googleImage(title):

    scrapedData = []

    query = urllib.parse.quote_plus(title)
    # response = get_source("https://www.google.co.uk/search?q=" + query)
    response = get_source("https://en.wikipedia.org/wiki/" + query)

    soup = bs4.BeautifulSoup(response.text,"html.parser")
                        
    image_object=soup.find_all( "td", {"class":"infobox-image"} )
    # print(type(image_object))

    scrapedData.append('Title: ' +title)

    for div in image_object:
        image = (div.find('img')['src'])
        print(div.find('img')['src'])
        scrapedData.append('https:' +image)
    
    return scrapedData

# Test Function
print("hi")
get_googleImage("Brad_pitt")


# Apply data scraping function on all movie/show titles in dataset and save info into new CSV
data = pd.read_csv('datasets/IMDB image scraping.csv',nrows=20)
goolgeInfo = data['Wiki_Name'].apply(get_googleImage)
goolgeInfo.to_csv('wikiInfo.csv', encoding='utf-8', index=False)

