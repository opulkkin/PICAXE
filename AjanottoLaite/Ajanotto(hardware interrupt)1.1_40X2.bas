' Ajanotto PICAXE 40X2:lla infrapunaportteja k�ytt�en. T�ll� ohjelmalla maksimi mittausaika on n. 4,6 s.
'
' Olli Pulkkinen
'
' 31.3.2016
'
' T�ss� ohjelmassa olisi siis tarkoitus k�ytt�� hintsetup- ja setintflags-komentoja.
' N�ill� saadaan interrupt tiettyyn jalkaan ja timerin ylivuodon interrupt yhdistetty� k�tev�sti.
' Testaamalla havaittiin ett� t�m� ohjelma mittaa aikaa tarkemmin kuin muut ohjelmaversiot.
' 
' Ohjelma on muuten sama kuin edellinen ohjelmaversio 1.0, mutta ajan laskenta aliohjelmassa laskeAikaJaLaheta
' on tehty eri tavalla. Laskennan tulos on kuitenkin aina sama kuin edellisess� ohjelmaversiossa.
'
'
' T�ss� ohjelmassa on valittu niin ett� ajanotto alkaa kun B.0-pinni nousee high-tilaan
' ja ajanotto loppuu kun B.1-pinni nousee high-tilaan.
'




alustukset:

   setfreq em32       ' ulkoinen 8MHz:n resonaattori k�ytt��n. Lopullinen kellotaajuus on siis nyt 32 MHz.

   pause 2000
   
   disconnect        ' laitetaan ohjelmalatauksen tarkistus pois p��lt�, koska t�st�
                     ' saattaa tulla ylim��r�ist� mittausvirhett�.
   
   
   'infrapunaportit ovat B.0:ssa ja B.1:ss�. Muut pinnit joita k�ytet��n:
   
   
   symbol vihreaLedi = B.3     
   
  
   symbol merkkiLediStart = B.4   
   
  
   symbol merkkiLediMaali = B.5
  
   
   symbol nollauskytkin = pinB.7
   
   ' 7-segmenttin�yt�ille tulostaminen hoidetaan D-, C- ja A-porttien avulla.
   
   
   ' Muutamia apumuuttujia joita k�ytet��n ajanotossa ja ajan laskemisessa(mittaustuloksen muuttaminen sekunneiksi).
   
   symbol muistiNro = b53
  
   muistiNro = 0

   symbol kierrokset = b51

   kierrokset = 0


   symbol ajanOttoAloitettu = b52    ' sis�ltyy w26:een

   ajanOttoAloitettu = 0    ' Olisi 0 my�s ilman t�t� sijoituslausetta, mutta ohjelman ymm�rt�minen
                            ' saatta helpottua kun alkuarvo n�kyy selv�sti.
   
   symbol aika = w27
   
   ' Nyt b0...b51 ovat k�ytett�viss� muuhun tarkitukseen.
   
   let dirsD = %11111111  ' N�m�  letdirs-komennot ovat 7-segmenttin�ytt�j� varten. 
                          ' Kaikki D-, C- ja A- portin pinnit valitaan ulostuloiksi.
   let dirsC = %11111111

   let dirsA = %11111111 
 
  ' Ei k�ytet� A.4:sta 7-segmenttin�yt�ille, koska se on serout-pinni. J�tet��n k�ytt�m�tt� my�s pinni C.4,
  ' mutta D.4 k�ytet��n desimaalipisteen tulostamiseen.
  ' K�ytet��n siis D-porttia sekunneille, C-porttina kymmenesosille ja A-porttia sadasosille.
   
   
  ' Menn��n aluksi aliohjelmaan herkkyysSaato, jossa voidaan s��t�� fototransistoreiden kanssa sajassa olevien
  ' s��t�vastusten arvot sopiviksi. Kun painetaan nollauskytkint�(pinB.7), niin p��st��n aloittamaan ajanotto.
   
   
   gosub herkkyysSaato
   
  
  ' Tyhjennet��n 7-segmenttin�yt�t. N�yt�t nollataan kyll� ohjelman alussa my�s ilman t�t� lausetta, mutta
  ' tuleepahan selv�ksi ett� alussa n�yt�iss� ei pit�isi n�ky� mit��n.
  
   gosub tyhjennaNaytot 
 
  
  ' pause 4000
  
    
   settimer off
      
   timer = 0
  
  
   ' Seuraavat kaksi komentoa alustavat hardware interruptin pinniin B.0. Kun n�iden komentojen j�lkeen
   ' pinniss� B.0 tapahtuu siirtym� 0 -> 1, niin hyp�t��n eritt�in nopeasti interrupt-aliohjelmaan.
   
   
   hintsetup %00010001
   
   setintflags %00000001, %00000001
   
   
   'Vihre� ledi palaa aina merkkin� siit�, ett� ollaan valmiina ottamaan uusi aika.
  
   high vihreaLedi
   
   
main:
                ' P��ohjelmassa ei tehd� mit��n muuta kuin py�rit��n rinki� ja odotetaan
                ' interruptia. Vaikuttaa aika hassulta, mutta testien perusteella t�m� on nopein
                ' tapa reagoida pinnin tilan muuttumiseen!               
   goto main
   

interrupt:

  
   if ajanOttoAloitettu = 0 then  ' T�m� if lauseke suoritetaan jos ajanottoa ei ole aloitettu
                                  ' T�t� if-lauseketta vastaava else suoritetaan jos ajanotto on aloitettu.
      
      
                              ' Nyt siis pit�isi k�ynnist�� ajanotto. Tarkin mahdollinen menetelm�
                              ' ajanottoon on k�ytt�� settimer komentoa ja mahdollisimman suurta
                              ' preload-arvoa komennossa. Timer3:n k�ytt� olisi toinen vaihtoehto, mutta
                              ' mittaustarkkuus ei ole silloin yht� hyv�.
      
      pause 28                ' Kalibrointipause. Jostain syyst� mittausajat ovat hieman liian
                              ' pitki� vaikka luulisi niiden olevan hieman liian lyhyit�, koska
                              ' alunperin kalibrointi tehty s.e. settimer on ollut jo asetettuna
                              ' kun alkuaika on otettu. Nyth�n nimitt�in ajanoton alussa 
                              ' vasta alustetaan timer! senkin luulisi viev�n aikaa...
     
     
      settimer 65531          ' Havaittiin ett� settimer ei toimi 65531:st� suuremmilla preload-arvoilla.
   	                        ' Siis 65531 on maksimiarvo t�ss�(Manuaali ei tiennyt t�st� mit��n...:) ).
                              ' T�ll� arvolla saadaan tarkin mahdollinen mittaus.
      
      
      low vihreaLedi          ' Kun ajanotto k�ynnistyy, niin sammutetaan vihre� ledi.
      
      
      ajanOttoAloitettu = 1   ' Asetetaan 1:ksi merkkin� siit� ett� ajanotto on p��ll�.
     
     
     
      flags = %00000000       ' Lippubitit eiv�t nollaudu automaattisesti.
     
      
      ' Seuraavien komentojen suorituksen j�lkeen(ja interruptista poistumisen j�lkeen) aliohjelmaan
      ' interrupt hyp�t��n takaisin jos pinni B.1 siirtyy 0 -> 1 tai timerissa tulee ylivuoto (65535 -> 0). 
      ' Ylivuototilanne tulee n. 4,6 s kuluttua mittaamisen aloituksesta.
     
      hintsetup %00100010
   
      setintflags OR %10000010, %10000010
   
    
   
   else              ' T�m� suoritetaan siis jos ajanotto on aiemmin aloitettu.
      
      aika = timer   ' Otetaan v�litt�m�sti timerin lukema muistiin.
      
      ajanOttoAloitettu = 0
      
      
      if toflag = 1 then  'jos timerissa ylivuoto
      
         settimer off
     
         timer = 0 
         
         low vihreaLedi
         
         sertxd("ylivuoto timerissa", 13, 10) 'Tietokoneelle l�hetet��n teksti "ylivuoto timerissa"
         
         'tulostetaan 7-segmenttin�yt�olle kolme viivaa merkkin� siit� ett� aikaa ei saatu mitattua.
         
         gosub tulostaViivat
         
           
      else               ' T�m� suoritetaan jos aika on saatu normaalisti mitattua.
      
         settimer off
      
         timer = 0
      
        
         gosub laskeAikaJaLaheta  ' LaskeAikaJaLaheta muuttaa mitatun timerin lukeman sekunneiksi ja py�rist��
                                  ' tuloksen kahden desimaalin tarkkuudelle. Tulos l�hetet��n tietokoneelle sek�
                                  ' tarkkana ett� py�ristettyn� ja 7- segmenttin�yt�ille tulostetaan py�ristetty
                                  ' lukema.
         
         'pause 1000                
      
         
      endif
      
      ' J��d��n py�rim��n silmukkaan siihen asti kunnes painetaan nollauskytkint�.
         
      do
         
         
      loop until nollauskytkin = 1
      
      
      gosub tyhjennaNaytot  ' Tyhjennet��n 7-segmenttin�yt�t.
       
     
      high vihreaLedi       ' Laitetaan vihre� ledi palamaan merkkin� siit�, ett� voidaan mitata uusi aika.
      
     
      flags = %00000000     ' Lippubitit eiv�t nollaudu automaattisesti.
   
      ' Seuraavat kaksi komentoa alustavat hardware interruptin pinniin B.0. Kun n�iden komentojen j�lkeen
      ' (ja interrupt-aliohjelmasta poistumisen j�lkeen) pinniss� B.0 tapahtuu siirtym� 0 -> 1, niin hyp�t��n 
      ' eritt�in nopeasti takaisin  interrupt-aliohjelmaan.
   
      hintsetup %00010001
   
      setintflags %00000001, %00000001
   
   endif 
   
   
   return





laskeAikaJaLaheta:

   ' T�ss� aliohjelmassa lasketaan PICAXEn timerin muutosta vastaava aika sekunteina ja l�hetet��n
   ' tulos tietokoneelle(tarkka lukema ja kahden desimaalin tarkkuudelle py�ristetty lukema) ja kahden desimaalin
   ' tarkkuudelle py�ristetty lukema laitetaan my�s 7-segmenttin�yt�ille.

   ' Havaittiin, ett� pit�� laskea 0,070466459*x + 1,322745133, miss� x on timerin lukeman muutos, 
   ' joka on nyt w4:ssa. T�m� antaa todellisen ajan millisekunteina. Nyt siis 0 <= x <= 65535
   ' Kaava l�ydettiin mittaamalla kymmeni�tuhansia eri timerin muutoksia vastaavia aikoja tietokoneella,
   ' ja tekem�ll� havaintoaineistolle pns-sovitus(Siis kymmeni�tuhansia mittauksia ei tietenk��n tehty yksi
   ' kerrallaan vaan mittauksia varten tehtiin oma ohjelmansa PICAXElle ja toinen tietokoneelle jotka hoitivat 
   ' mittamisen ja tietokoneen ohjelma kirjoitti mittaustulokset tiedostoon tietokoneelle.). T�ll�in havaittiin, 
   ' ett� mittaustulokset asettuivat hyvin tarkasti samalle suoralle ja sovituksesta saatiin kulmakerroin ja vakiotermi,
   ' joiden avulla aika voidaan laskea kun timerin muutos tiedet��n.
   '
   ' Voidaan luonnolllisesti laskea my�s 70466459*x + 1322745133, mist� saadaan aika yksik�ss�
   ' 10^(-9) ms. Lopuksi tietokoneelle l�hetyksess� lis�t��n pilkku oikeaan paikkaan jotta saadaan
   ' aika sekunteina.
   '
   ' Huom. settimer- komennon toteutus PICAXE- j�rjestelm�ss� on aika karkeasti virheellinen, 
   ' eli komento ei toimi k�yt�nn�ss� l�hellek��n sill� tavalla kuin sen manuaalin mukaan
   ' pit�isi toimia. Yll� esitetyn sovitussuoran aulla voidaan kuitenkin aina laskea vastaava
   ' todellinen aika kun timerin muutos on mitattu. Laskukaava antaa oikeita tuloksia vain 32MHz:n 
   ' kelllotaajuudella ja settimer-komennon preload-arvolla 65531.
   
   
   ' Seuraavana pit�isi siis laskea lasku 70466459*x + 1322745133, miss� x on timerin lukema, joka on nyt
   ' muuttujassa aika(=w27). Ongelmana on se, ett� PICAXE:n aritmetiikka on toteutettu vain maksimissaan
   ' 16-bittisille kokonaisluvuille, eli siis 65535 on maksimi arvo mik� voi esiinty� matemaattisissa
   ' laskutoimituksissa. Siis laskutoimitusta ei voida tehd� suoraan. On siis keksitt�v� jokin toinen menetelm�
   ' laskun laskemiseksi. Tosin laskua ei tarvitsisi tehd� n�in suurella tarkkuudella ja laskenta helpottuisi jos
   ' operandeja hieman py�ristelt�isiin. On kuitenkin ihan mielenkiintoinen matemaattinen ja ohjelmallinen harjoitus-
   ' teht�v� laskea lasku yll� esitetyill� isoilla luvuilla(ts. "tarkoilla" arvoilla). 
   
   ' Edellisess� ohjelmaversiossa laskettiin lasku siten, ett� jokaiselle numerolle k�ytettiin
   ' omaa 8-bitin muistipaikkaa RAM-muistista ja py�r�ytettiin l�pi jo alakoulusta tuttu kertolaskualgoritmi.
   ' Tosin ohjelmakoodina lasku n�ytt�� melko sekavalta ja algoritmi tuhlaa kohtuuttoman paljon muistipaikkoja eik�
   ' varmasti ole my�sk��n ajank�yt�lt��n kovin hyv�!(Tosin muistia ei tarvita nyt muuhunkaan eik� laskuaikakaan ole
   ' k�yt�nn�ss� pitk�).
 
   ' Seuraavaavassa on ehk� j�rkev�mpi tapa toteuttaa lasku. Siin� ajatellaan laskussa kaikki operandit
   ' bin��rilukuina (tai 256-kantaisessa tai 65536-kantaisessa lukuj�rjestelm�ss�) ja suoritetaan lasku 
   ' k�ytt�en PICAXE:n valmista aritmetiikkaa 16-bitin luvuille(ks. manuaalin osa 2 sivulta 22 alkaen). 
   ' Menetelm� kuitenkin vaatii jonkin verran alkeellisen lukuteorian osaamista, erityisesti t�ytyy hallita 
   ' jakoj��nn�slaskentaa(j��nn�sluokka-aritmetiikka mod n) ja luvun esitt�minen muissakin lukuj�rjestelmiss� kuin 
   ' pelk�st��n tutussa 10-j�rjestelm�ss�.
   ' Lis�ksi t�ytyy ymm�rt�� jakokulman algoritmi sen verran syv�llisesti, ett� osaa k�ytt�� sit� my�s muissa kuin 
   ' 10-kantaisessa lukuj�rjestelm�ss�. Mutta mit��n oikeasti syv�llist� matematiikkaa ei kuitenkaan tarvita.
   ' 
   ' Etsit��n aluksi laskussa esiintyvien lukua 65535 suurempien kokonaislukujen bin��riesitykset ja esitykset:
   ' 256-kantaisessa ja 65526-kantaisessa lukuj�rjestelm�ss�.
   '
   '
   ' 70466459 = 2^26 + 2^21 + 2^20 + 2^17 + 2^16 + 2^13 + 2^12 + 2^11 + 2^9 + 2^8 + 2^7 + 2^4 + 2^3 + 2^1 + 2^0
   '
   '          = 100001100110011101110011011 = 4*256^3 + 51*256^2 + 59*256^1 + 155*256^0 = 004051059155 (256-j�rj.)
   '
   '          = 1075*65536^1 + 15259*65536^0 = 0107515259(65536-j�rjestelm�ss�)
   '
   '
   ' Yleens� lukuj�rjestelmiss� otetaan kirjaimet k�ytt��n silloin kuin kantaluku > 10, mutta
   ' kun j�rjestelm�ss� on 256(tai 65536) eri merkki� niin on ehk� j�rkev�mp�� k�ytt�� esim. kolmen numeron jonoa
   ' yhden merkin esitt�miseen. Siis 256-kantaisen lukuj�rjestelm�n "numerot" ovat t�ll� merkinn�ll�
   ' 000,001,002,...,253,254,255. T�ss� on my�s se hyv� puoli, ett� laskenta toimii odotetulla tavalla jatkossa,
   ' koska n�in m��ritellyille kehitelm�n "numeroille" on esim. suuruusj�rjestys m��ritelty luonnollisella tavalla.
   ' Vastaavalla tavalla on tehty 65536-j�rjestelm�ss�, miss� "numerot" koostuvat 5-pituisista merkkijonoista.
   
   
   ' 1322745133 = 2^30 + 2^27 + 2^26 + 2^25 + 2^23 + 2^22 + 2^20 + 2^18 + 2^17 + 2^16 + 2^14 + 2^13 + 2^12 + 2^11 + 2^10
   '             
   '              + 2^8 + 2^5 + 2^3 + 2^2 + 2^0 = 1001110110101110111110100101101
   '
   '            = 78*256^3 + 215*256^2 + 125*256^1 + 45*256^0 = 078215125045  (256-j�rjestelm�ss�)
   '
   '            = 20183*65536^1 + 32045*65536^0 = 2018332045 (65536-j�rjestelm�ss�) 
   
   ' Kertoimen 704666459 65536-kantaisen j�rjestelm�n "numerot" ovat 1075(enemm�n merkitsev�) ja 15259(v�hemm�n merkitsev�)
   '
   ' Vakion 1322745133 65536-kantaisen j�rjestelm�n "numerot" ovat 20183(enemm�n merkitsev�) ja 32045(v�hemm�n merkitsev�)
   '
   ' Annetaan n�ille "vakionumeroille" nimet, jolloin ohjelman muokkaaminen helpottuu jos niit� tarvitsee joskus
   ' muuttaa. Aivan mit� tahansa arvoja ei voi n�ille vakioille antaa, kuten alla olevasta koodista selvi��.
   
     symbol kerroin0 = 15259  ' T�m�n pit�� olla <=65535
     
     symbol kerroin1 = 1075   ' T�m�n pit�� olla <=65534
   
     symbol vakio0 = 32045    ' T�m�n pit�� olla <=65535
   
     symbol vakio1 = 20183    ' T�m�n pit�� olla <=65534
   
   ' Seuraaavana lasketaan 70466459*aika ja tallennetaan tulos kolmeen sanamuuttujaan w4, w5 ja w6.
   
   ' Kun kertolasku suoritetaan 65536-kantaisessa lukuj�rjestelm�ss�, saadaan
   ' (kerroin1*65536^1 + kerroin0*65536^0) * aika = kerroin1*aika*65536^1 + kerroin0*aika*65536^0
   ' Kun laskun kerroin1*aika 16 v�hiten merkitsev�� bitti� sijoitetaan muistipaikkaan w3 ja 16 eniten merkitsev��
   ' bitti� w2:iin, ja vastaavasti laskun kerroin0*aika 16 v�hiten merkitsev�� bitti� sijoitetaan w0:iin ja
   ' 16 eniten merkitsev�� bitti� sijoitetaan w4:n saadaan laskun tulos ainakin teoriassa esitetty� muodossa
   ' w2*65536^2 + (w3 + w4)*65536^1 + w0. T�ss� on vain yksi ongelma, nimitt�in w3 + w4 saattaa menn� yli arvon
   ' 65535 ja t�ll�in ylivuotobitit menetet��n ja lasku ei anna oikeaa tulosta. On kuitenkin helppo testata milloin
   ' 16 bitin aritmetiikassa tapahtuu ylivuoto laskettaessa w3 + w4. P�tee nimitt�in seuraava tulos(helppo osoittaa):
 
   ' Laskettaessa w3 + w4 tapahtuu ylivuoto jos ja vain jos w3 + w4 < w3 ja w3 + w4 < w4
   '
   ' Itse asiassa ylivuoto on viel� yht�pit�v�� sen kanssa ett� w3 + w4 < w3, mik� vastaavasti on viel� yht�pit�v��
   ' sen kanssa ett� w3 + w4 < w4, joten riitt�isi testata esim. w3 + w4 < w3, mutta eip� se haittaa vaikka
   ' yksi turha testaus tehd��nkin.
   '
   ' T�m�n avulla voidaan p��tell�, ett� seuraava algoritmi antaa j�rkev�n tuloksen:
   ' Sijoitetaan laskun kerroin1*aika 16 v�hiten merkitsev�� bitti� muistipaikkaan w3 ja 16 eniten merkitsev��
   ' bitti� w2:iin, ja vastaavasti laskun kerroin0*aika 16 v�hiten merkitsev�� bitti� w0:iin ja
   ' 16 eniten merkitsev�� bitti� w4:een. Sijoitetaan w1 = w3 + w4. Testataan onko voimassa w1 < MIN(w3, w4)
   ' Jos t�m� on voimassa, niin on tapahtunut ylivuoto, jolloin kasvatetaan w2 yhdell�. Jos t�m� ei ole voimassa, niin
   ' ylivuotoa ei ole tapahtunut ja w2:lle ei tehd� mit��n. 
   ' N�iden operaatioiden j�lkeen laskun 70466459*aika tulos saadaan muistipaikkojen w2, w1 ja w0 avulla muodossa
   ' w2*65536^2 + w1*65536^1 + w0*65536^0.
   '
   ' Toteutetaan seuraavaksi yll� esitetty idea:
   '
   
   w3 = kerroin1*aika   ' kertolaskun 16 v�hiten merkitsev�� bitti�
   
   w2 = kerroin1**aika  ' kertolaskun 16 eniten merkitsev�� bitti�
   
   w0 = kerroin0*aika  ' kertolaskun 16 v�hiten merkitsev�� bitti�
   
   w4 = kerroin0**aika ' kertolaskun 16 eniten merkitsev�� bitti�
   
   
   w1 = w3 + w4
   
   
  
   
   ' Seuraavassa testataan onko voimassa w1 < w3 ja w1 < w4 ja jos on niin lis�t��n w2:n arvoa yhdell�.
   
   if w1 < w3 AND w1 < w4 then
   
      inc w2
   
   endif
   
   
   ' Nyt siis laskun 70466459*aika tulos saadaan muistipaikkojen w2, w1 ja w0 avulla muodossa
   ' w2*65536^2 + w1*65536^1 + w0*65536^0. w3, w4  ovat vapaasti k�ytett�viss� jatkossa.
   
   ' Seuraavaksi pyrit��n lis��m��n luku 1322745133 = vakio1*65536^1 + vakio0*65536^0 edell� lasketun kertolaskun
   ' tulokseen. T�m� vaihe on oikeastaan turha, mutta tehd��n se sen vuoksi ett� t�m� aliohjelma antaa saman tuloksen 
   ' kuin edellisen ohjelmaversion vastaava aliohjelma.
   ' Yhteenlasku saadaan esitetty� muodossa
   '
   ' 70466459*aika + 1322745133 = w2*65536^2 + w1*65536^1 + w0*65536^0 + vakio1*65536^1 + vakio0*65536^0
   '
   ' = w2*65536^2 + (w1 + vakio1)*65536^1 + (w0 + vakio0)*65536^0.
   '
   ' T�ss� pit�� taas muistaa ottaa huomioon my�s tapaukset, jolloin w0 + vakio0 vuotaa yli 16-bittisest� muistipaikasta
   ' jne. Tallennetaan ensin laskun w0 + vakio0 tulos muistipaikkaan w3 ja toimitaan hieman samaan tapaan kuten 
   ' edell� kertolaskun yhteydess�:
   
   w3 = w0 + vakio0
   
    ' Seuraavassa testataan onko voimassa w3 < vakio0 ja w3 < w0 ja jos on niin asetetaan muistiNro:ksi 1(muutoin == 0).
   
   if w3 < vakio0 AND w3 < w0 then
   
       muistiNro = 1
   
   endif
   
   ' Sijoitetaan summa takaisin w0:aan, jonka j�lkeen w3 on taas k�yt�ss� muuhun tarkoitukseen.
   ' w0 pit�� siis t�m�n j�lkeen sis�ll��n laskun tuloksen "ensimm�isen numeron" 65536-kantaisessa j�rjestelm�ss�, ts.
   ' laskun lopputuloksen 16 v�hiten merkitsev�� bitti�.
  
  
   w0 = w3
   
   
   ' Lasketaan w3:aan seuraavaksi vakio1 + muistiNro. T�ss� ei tule ylivuotoa kunhan vakio1 <= 65534
   
   w3 = vakio1 + muistiNro
   
   ' Lasketaan sitten w4:een w1 + vakio1 + muistiNro = w1 + w3. T�m�n j�lkeen w4 pit�� sis�ll��n laskun tuloksen
   ' "toisen numeron" 65536-kantaisessa j�rjestelm�ss�, ts. laskun lopputuloksen 16 keskimm�ist� bitti�.
   '
   
   w4 = w1 + w3
   
   
   if w4 < w1 AND w4 < w3 then  ' Jos on tapahtunut ylivuoto laskussa w1 + w3 = w1 + vakio1 + muistiNro
                                ' muistetaan kasvattaa w2:sta 1:ll�. w2 antaa siis laskun lopuutuloksen
       inc w2                   ' 16 eniten merkitsev�� bitti�.
   
   endif
   
   'Sijoitetaan viel� keskimm�iset bitit w4:sta w1:een.
   
   w1 = w4
   
   ' T�m�n j�lkeen laskun 70466459*aika + 1322745133 lopputulos on muuttujissa w2, w1 ja w0 s.e. tulos saadaan
   ' laskemalla w2*65536^2 + w1*65536^1 + w0*65536^0. w3, w4 ja w5 ovat taas k�ytett�viss� muuhun tarkoitukseen jatkossa.
   
   ' Nyt seuraavaksi haluttaisiin siis saada t�m�n laskun w2*65536^2 + w1*65536^1 + w0*65536^0 vastaus tutussa 10-
   ' kantaisessa lukuj�rjestelm�ss�. Miten se onnistuu? Idea on seuraava:
   ' Lasketaan ensin laskun tuloksen jakoj��nn�s, kun tulos jaetaan sadalla. Jakoj��nn�ksen� saadaan jokin luku s.e.
   ' 0 <=luku < 99. Huomaa ett� t�m� luku antaa siis laskun w2*65536^2 + w1*65536^1 + w0*65536^0 tuloksen kaksi v�hiten 
   ' merkitsev�� numeroa 10-j�rjestelm�ss�. V�hennet��n seuraavaksi w2*65536^2 + w1*65536^1 + w0*65536^0 - luku, 
   ' ja sijoitetaan v�hennyslaskun tulos takaisin muistipaikkoihin w2, w1 ja w0 s.e. v�hennyslaskun tulos saadaan 
   ' muodossa w2*65536^2 + w1*65536^1 + w0*65536^0. Nyt tiedet��n, ett� t�m�n laskun tulos on sadalla jaollinen.
   ' Jaetaan nyt laskun tulos sadalla ja sijoitetaan jakolaskun tulos takaisin muistipaikkoihin w2, w1 ja w0 s.e.
   ' jakolaskun tulos saadaan lausekkeesta w2*65536^2 + w1*65536^1 + w0*65536^0. Jos lasketaan t�m�n luvun jakoj��nn�s,
   ' kun se jaetaan sadalla, niin saadaan halutun vastauksen seuraavat kaksi numeroa. N�in jatketaan kunnes kaikki
   ' w2, ja w1 ja w0 ovat nollia. T�ll�in on saatu kaikki vastauksen numerot 10- j�rjestelm�ss� kuten haluttiin.
   
   
   ' Huomaa, ett� tulon jakoj��nn�s on aina yht� suuri kuin tulon tekij�iden jakoj��nn�sten tulon jakoj��nn�s :)
   ' Vastaava tulos p�tee summalle. Nyt 65536^2:n jakoj��nn�s sadalla jaettaessa on 96 ja 65536:n jakoj��nn�s sadalla
   ' jaettaessa on 36. N�it� k�ytet��n jatkossa moneen kertaan.
   
   
   do
   
      ' Lasketaan ensin w0:n, w1:n ja w2:n jakoj��nn�kset sadalla jaettaessa muuttujiin b6, b7 ja b8
   
      b6 = w0 % 100
   
      b7 = w1 % 100
   
      b8 = w2 % 100
   
      ' Lasketaan sitten aluksi w5:een koko lausekkeen w2*65536^2 + w1*65536^1 + w0*65536^0 jakoj��nn�s sadalla jaettaessa:
   
   
      w5 = b8 * 96  
   
      w6 = b7 * 36
   
      w5 = w5 + w6
   
      w5 = w5 + b6
      
      w5 = w5 % 100
      
      ' Sijoitetaan viel� tulos muuttujaan b6, jolloin b7, b8 jne. vapautuvat jatkok�ytt��n.
      
      b6 = w5 
      
      
     ' Pyrit��n sitten laskemaan v�hennyslasku w2*65536^2 + w1*65536^1 + w0*65536^0 - b6. Jos w0 >= b6, niin lopputulos
     ' saadaan yksinkertaisesti suoraan v�hent�m�ll� w0 - b6. Jos puolestaan w0 < b6, niin on lainattava enemm�n merkit-
     ' sevist� numeroista. Jos w1 >= 1, niin lainaus voidaan tehd� s.e. v�hennet��n w1:n arvoa yhdell� ja uusi w0 saadaan
     ' laskemalla 65536 + w0 - b6 = 65535 - b6 + w0 + 1 (N�in laskemalla v�ltyt��n ylivuodolta). Jos w1 == 0, niin lainaus 
     ' teht�v� w2:sta asti. T�ll�in w2:sta pit�� v�hent�� yhdell� ja asettaa w1 = 65535, ja laskea samaan tapaan kuin 
     ' edell� uusi w0 kaavasta 65536 + w0 - b6 = 65535 - b6 + w0 + 1. Huomataan kuitenkin ett� my�s tapauksessa w1 == 0
     ' voidaan laskea w1 - 1, Ja tulos on 65535 kuten pit��kin. Lis�ksi havaitaan, ett� my�s tapauksessa w0 < b0
     ' voidaan uuden w0:n laskeminen hoitaa kaavalla w0 - b6(hallittu alivuoto). Nyt siis on pohdittu miten v�hennyslasku 
     ' pit�� suorittaa kaikissa mahdollisissa tapauksissa. T�m� idea on toteutettu alla:
      
     
      
     if w0 < b6 then
     
         if w1 = 0 then
     
            dec w2         'T�m� v�hennys johtuu lainaamisesta
     
         endif
     
         dec w1         'T�m� v�hennys johtuu lainaamisesta
     
     endif
     
     w0 = w0 - b6    ' N�in siis saadaan kaikissa tapauksissa oikea w0.
     
    
     ' Nyt w2, w1 ja w0 pit�v�t sis�ll��n v�hennyslaskun tuloksen s.e. tulos on w2*65536^2 + w1*65536^1 + w0*65536^0
     
     
     ' Tallennetaan lopputuloksen numerot muistiin paikasta 16 l�htien. Siis kaksi v�hiten
     ' merkitsev�� numeroa l�ytyy muistipaikasta 16, seuraavat 2 paikasta 17 jne.
     
     
     bptr = kierrokset + 16
     
     @bptr = b6         ' Tallennetaan numerot bptr:n osoittamaan muistipaikkaan, eli paikasta 16 alkaen.
     
     inc kierrokset
     
    
     ' Paikasta 16 l�htien on ainakin jonkin matkaa muistissa lopputuloksen numeroita.
     ' Lopputuloksen tallettamiseen tarvitaan korkeintaan 8 muistipaikkaa, kun kaksi
     ' numeroa on yhdess� muistipaikassa.
     
     ' Seuraavaksi pit�isi siis tehd� jakolasku (w2*65536^2 + w1*65536^1 + w0*65536^0)/100 
     ' Laskennassa voi k�ytt�� apuna nyt esim. muistipaikkoja b6.....b15.
     '
     ' Jakokulman voisi kirjoittaa lyhyemmin silmukkarakenteen avulla, mutta se saataa
     ' hankaloittaa sen ymm�rt�mist�.
     '
     ' Havainnollistava kuva jakokulmasta:
     '
     '            b15b14....
     '            ____________
     '        100|b5b4b3b2b1b0
     '
     '            b7.
     '            .
     '
      
       
      b15 = b5/100     ' b15 pit�� siis nyt sis�ll��n jakolaskun tuloksen ensimm�isen "numeron"
     
      b7 = 100*b15     ' Kertolaskun tulos b7:aan
     
      b7 = b5 - b7     ' V�hennyslasku
      
      b6 = b4          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
   
     ' Nyt w3 = b7b6 pit�� sis�ll��n sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' toisen "numeron"
     
      b14 = w3/100    ' b14 pit�� siis sis�ll��n jakolaskun tuloksen toisen "numeron"
      
      w4 = 100*b14     ' Kertolaskun tulos w4:een
      
      b7 = w3 - w4     ' V�hennyslasku
      
      b6 = b3          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
      
      
     ' Nyt w3 = b7b6 pit�� sis�ll��n sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' kolmannen "numeron"
      
      b13 = w3/100    ' b13 pit�� siis sis�ll��n jakolaskun tuloksen kolmannen "numeron"
      
      w4 = 100*b13     ' Kertolaskun tulos w4:een
      
      b7 = w3 - w4     ' V�hennyslasku
      
      b6 = b2          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
      
      
     ' Nyt w3 = b7b6 pit�� sis�ll��n sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' nelj�nnen "numeron"
      
      b12 = w3/100    ' b12 pit�� siis sis�ll��n jakolaskun tuloksen nelj�nnen "numeron"
      
      w4 = 100*b12     ' Kertolaskun tulos w4:een
      
      b7 = w3 - w4     ' V�hennyslasku
      
      b6 = b1          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
      
      
     ' Nyt w3 = b7b6 pit�� sis�ll��n sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' viidennen "numeron"
      
      b11 = w3/100    ' b11 pit�� siis sis�ll��n jakolaskun tuloksen viidennen "numeron"
      
      w4 = 100*b11     ' Kertolaskun tulos w4:een
      
      b7 = w3 - w4     ' V�hennyslasku
      
      b6 = b0          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
      
      
     ' Nyt w3 = b7b6 pit�� sis�ll��n sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' kuudennen eli viimeisen numeron "numeron"
      
      b10 = w3/100    ' b10 pit�� siis sis�ll��n jakolaskun tuloksen viimeisen "numeron"
      
     ' Sijoitetaan seuraavaksi nyt w7:ssa(=b15b14), w6:ssa(=b13b12) ja w5:ssa(=b11b10) oleva 
     ' jakolaskun lopputulos takaisin muuttujiin w2, w1 ja w0.
      
      w2 = w7
      
      w1 = w6
      
      w0 = w5
      
      ' Jos viel� v�hint��n yksi w2, w1 tai w0 on nollasta eroava, niin kaikkia 10-j�rjestelm�n
      ' numeroita ei ole viel� etsitty. Jatketaan siis silmukkaa ja etsit��n lis�� numeroita.
      ' Jakokulma py�r�ytet��n oikeasataan turhaan yhden kerran viimeisell� kierroksella mutta
      ' eipa tuo haittaa.
      '
      
   loop until w2 = 0 AND w1 = 0 AND w0 = 0
   
   ' Nyt laskenta on valmis ja lopputulos on muistipaikoissa b16,b17,... s.e. v�hiten merkitsev�t kaksi numeroa ovat
   ' paikassa b16, seuraavat b17, jne.
   ' Montako muistipaikkaa numeroitten tallettamiseen on oikeastaan k�ytetty?
   ' Koska 70466459*aika + 1322745133 <= 70466459*65535 + 1322745133 == 4619342135698 ja kaksi numeroa on
   ' aina talletettuna yhteen muistipaikkaan, niin muistipaikkoja on k�ytetty 7. Siis lopullinen tulos saadaan
   ' 10-j�rjestelm�ss� suoraan s.e. tulos = b22b21b20b19b18b17b16. Sekunteina tulos saadaan t�st� kun lis�t��n pilkku
   ' kahden eniten merkitsev�n numeron v�liin.
   
   for b23 = 0 to 6          'numeroitten erottaminen erillisiin muistipaikkoihin ennen l�hetyst�.
   
      bptr = 16 + b23        ' v�hiten merkitsev� numero tulee siis b0:aan jne. Eniten merkitsev� b12:sta.
   
      b24 = @bptr
      
      bptr = b23 * 2
      
      @bptr = b24 % 10
      
      bptr = bptr + 1
      
      @bptr = b24/10
   
   next b23
   
   kierrokset = 0
   
   muistiNro = 0
   
   for b23 = 16 to 22 ' Nollataan viel� numeroitten sijoituspaikat, jotta ei tule jatkossa
                      ' v��ri� lukemia
      bptr = b23 
                      
      @bptr = 0
   
   next b23
   
   
   ' Nyt lopputulos on muistipaikoissa b12,...,b0 s.e. v�hiten merkitsev� numero on b0:ssa
   ' Sekunteina lopputulos saadaan kun lis�t��n pilkku b12 ja b11 v�liin.
   
   ' L�hetet��n seuraavassa tarkka aika tietokoneelle.
   
   ' l�hetett�v� 44 on pilkun ascii-koodi.
   
   
   sertxd(#b12,44,#b11,#b10,#b9,#b8,#b7,#b6,#b5,#b4,#b3,#b2,#b1,#b0," s", 13, 10) 
 
   
  
   ' Laitetaan viel� sekunnit(b12), kymmenesosat(b11) ja sadasosat(b10) 7 segmenttin�yt�ille.
    
   ' Tehd��n t�t� ennen kuitenkin py�ristys kahden desimaalin tarkkuudelle tavallisen py�ristyss��nn�n mukaisesti.
   ' Muut tapaukset ovat helppoja paitsi se, kun toinen desimaali(b9) on 9 ja kolmas v�lill� 5 - 9.
   
   if b9 >= 5 then
   
      if b10 < 9 then
      
         inc b10
      
      else        ' nyt siis b9 = 9
      
         b10 = 0
      
         if b11 < 9 then
         
            inc b11
         
         else      ' nyt siis b10 = 9 ja b11 = 9
         
            b11 = 0
         
            inc b12    ' tiedet��n ett� nyt varmasti 0 <= b12 <= 4
            
            
         endif
      
      endif 
   
   endif
   
   
   'Tulostetaan sadasosien tarkkuudelle py�ristetty versio nyt ensin tietokoneella.
   
   sertxd("Py�ristetty tulos: ",#b12,44,#b11,#b10," s", 13, 10)
   
   
 
   ' 
   '
   ' D-, C-, ja A-porttien jalat ja vastaavat 7-segmenttin�ytt�jen ledit.
   ' D-portti tulostaa sekunnit, C-portti kymmenesosasekunnit ja A-portti sadasosasekunnit.
   '           
   '                2
   '              ------
   '             |      |
   '            1|      |3
   '             |  0   |
   '             |------|     Desimaalipisteelle k�ytet��n D-portin 4-pinni�
   '             |      |
   '            5|      |7
   '             |      |
   '              ------ 
   '                6
   '
   '
   '
   
   
   'Laitetaan ensin sekunnit ensimm�iselle 7-segmenttin�yt�lle(kytketty D-porttiin): 
   'Periaatteessa riit�isi tarkastella vain arvot 0 <= b12 <= 4, koska b12:ssa
   'ei voi nyt olla 4:sta suurempia arvoja.
 
  
 
    select b12
   
      case 0
   
         let pinsD = %11111110
                      
      case 1
      
         let pinsD = %10011000
   
      case 2
  
         let pinsD = %01111101
   
      case 3
  
         let pinsD = %11011101
   
      case 4
  
         let pinsD = %10011011
   
      case 5
  
         let pinsD = %11010111
   
      case 6
  
         let pinsD = %11110111
   
      case 7
  
         let pinsD = %10011100
   
      case 8
  
         let pinsD = %11111111
   
      case 9
  
         let pinsD = %11011111
   
   endselect
   
   
 
   'Laitetaan sitten kymmenesosat toiselle 7-segmenttin�yt�lle(kytketty C-porttiin):
 
   select b11
   
      case 0
   
         let pinsC = %11101110
                      
      case 1
      
         let pinsC = %10001000
   
      case 2
  
         let pinsC = %01101101
   
      case 3
  
         let pinsC = %11001101
   
      case 4
  
         let pinsC = %10001011
   
      case 5
  
         let pinsC = %11000111
   
      case 6
  
         let pinsC = %11100111
   
      case 7
  
         let pinsC = %10001100
   
      case 8
  
         let pinsC = %11101111
   
      case 9
  
         let pinsC = %11001111
   
   endselect
   
   
   'Laitetaan sitten sadasosat kolmannelle 7-segmenttin�yt�lle(kytketty A-porttiin):
 
    select b10
   
      case 0
   
         let pinsA = %11101110
                      
      case 1
      
         let pinsA = %10001000
   
      case 2
  
         let pinsA = %01101101
   
      case 3
  
         let pinsA = %11001101
   
      case 4
  
         let pinsA = %10001011
   
      case 5
  
         let pinsA = %11000111
   
      case 6
  
         let pinsA = %11100111
   
      case 7
  
         let pinsA = %10001100
   
      case 8
  
         let pinsA = %11101111
   
      case 9
  
         let pinsA = %11001111
   
   endselect
  
   
   
   return
 
 
   
   
   
tyhjennaNaytot:


   
   let pinsD = %00000000

   let pinsC = %00000000
  
   let pinsA = %00000000


   return
   
   
tulostaViivat:


   let pinsD = %00000001
         
   let pinsC = %00000001
         
   let pinsA = %00000001


   return
  
   
herkkyysSaato:

   
   do
    
      if pinB.0 = 1 then
      
         high merkkiLediStart
      
      else
      
         low merkkiLediStart
      
      endif   
    
    
      if pinB.1 = 1 then
      
         high merkkiLediMaali
      
      else
      
         low merkkiLediMaali
      
      endif 
         
         
   loop until nollauskytkin = 1


   return  