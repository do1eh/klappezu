#!/usr/bin/python
# -*- coding: iso-8859-1 -*-
# 
# 18.07.2015 DO1EH
# Auslesen der jsondaten vom dump1090 und schliessen des Fensters, 
# wenn sich ein Flugzeug in einem bestimmten Planquadrat befindet, niedriger als eine bestimmte Höhe fliegt
# und sich in eine bestimmte Richtung bewegt.
#
# Vorausetzung:
# dump1090 muss mit dem Befehl "./dump1090 --net --quiet" gestaret worden sein.
#
# Testaufbau: 
# Statt der Fenstersteuerung soll einfach eine LED leuchten oder nicht.
# An GPIO4 liegen 3,3V an wenn ein Flugzeug in der Nähe ist und 0V wenn nicht.
# Im Echtbetrieb sollte umgekehrt sein, da man immer mit geschlossenem Fenster und 0V startet.
# Wenn nun auch tatsächlich kein Flugzeug da ist sollte sich das Signal ändern (auf 3.3V) um
# das Fenster das erste mal zu öffnen. 
#
#json format von dump1090
#[
#   {  
#      "hex":"400db2",
#      "squawk":"4665",
#      "flight":"EZY96RV ",
#      "lat":45.183609,
#      "lon":-32.979694,
#      "validposition":1,
#      "altitude":30700,
#      "vert_rate":896,
#      "track":344,
#      "validtrack":1,
#      "speed":440,
#     "messages":175,
#      "seen":0
#   }
#] 


import requests, json, time, RPi.GPIO as GPIO

#Maximale Flughöhe 
maxh=12000

#Richtung des Fluges in Grad von-bis
richtungVon=0
richtungBis=360

#Koordinaten des Planquadrats festlegen:



#Lotti   		
#Oben rechts:
latOR= 51.314961
lonOR= 6.721438
#Unten links:
latUL= 51.204314
lonUL= 6.503428

#LED initialisieren
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(4, GPIO.OUT)

def oeffneFenster():
	GPIO.output(4,False)

def schliesseFenster():
	GPIO.output(4,True)

def datum():
	 
	return time.strftime("%d.%m.%Y")

def uhrzeit():
	return time.strftime("%H:%M:%S")

#Starten immer mit geschlossenem Fenster
fensterOffen=False

while True: 
	flugzeugImBereich=False
	#Json holen und parsen
	r = requests.get("http://127.0.0.1:8080/dump1090/data.json")
	data=r.json 
	for flight in data:
   		lat=flight['lat']        # Position Breitengrad
   		lon=flight['lon']        # Position Längengrad
   		alt = flight['altitude'] # Flughöhe un Fuß
		track=flight['track']    # Flugrichtung in Grad
		seen = flight['seen']    # Keine Änderung der Daten seit x sekunden
 		#Daten auswerten und Fenster steuern
   		if alt < maxh and seen<60\
                   and lat < latOR and lat > latUL and lon < lonOR and lon > lonUL\
                   and richtungVon <= track and richtungBis >= track:
			flugzeugImBereich=True;
			flugnr = flight['flight']
	if flugzeugImBereich and fensterOffen:
		schliesseFenster()
		fensterOffen=False
		print('Schliesse Fenster für Flug ' + str(flugnr) + 'um ' + uhrzeit() + ' Uhr.')
	elif not flugzeugImBereich and not fensterOffen:
		oeffneFenster()
		fensterOffen=True
		print('Fenster offen seit ' + uhrzeit() + ' Uhr.')		 
	time.sleep(5)
