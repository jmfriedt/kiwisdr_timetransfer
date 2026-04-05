# screen -L -Logfile logfile.txt -d -m python3 ./WebSDRcat.py
import time                 # for sleep
from selenium import webdriver                  # for browser control
from selenium.webdriver.common.by import By     # for browser control
URL='http://websdr.ewi.utwente.nl:8901/'  # WebSDR URL
options = webdriver.ChromeOptions()
options.add_argument("headless")
driver = webdriver.Chrome(options=options) # headless Chrome browser
driver.get(URL)
time.sleep(3)       # wait 3 seconds
script = "sethidelabels(1)" # hide labels
driver.execute_script(script)
while True:
# <input type="text" style="font-size:20px; text-align:center" size="10" name="frequency" onkeyup="setfreqif_fut(this.value);">
  freq_web=[]
  smeter=[]
  for freq in [77.5, 100.0, 162.0, 225.0]:
    driver.execute_script("set_mode('CW')") # set freq. by executing javascript cmd
    script = "setfreqb(" + '{:.2f}'.format(freq) + ")" # freq -> string
    driver.execute_script(script)
#    driver.execute_script("wfset(2)") # zoom in, in case the frequency has changed
    time.sleep(2)  # wait for power meter to settle
    tmp = driver.find_element(By.NAME, "frequency")     # read the freq from WebSDR 
    freq_web.append(float(tmp.get_attribute('value'))*1000.) 
    tmp = driver.find_element(By.ID, "numericalsmeter") # read Smeter
    smeter.append(float(tmp.text))
  print(f"{time.time()} {freq_web} {smeter}")
  time.sleep(60)
