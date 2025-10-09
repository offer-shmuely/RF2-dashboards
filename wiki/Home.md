### Rotorflight Suite of LUA scripts for EdgeTx

Note: The work is still work in progress, and probably will always be 😉, but I hope others will find it as useful as I do

![image](https://github.com/user-attachments/assets/7a98c153-4e23-4344-b4e4-c2acba6d116c)

---
### Rotorflight Configuration Script

[RF2_touch](https://github.com/offer-shmuely/rf2-touch-suite-edgeTx/wiki/RF_touch)

![image](https://github.com/user-attachments/assets/283c0318-3d70-498c-ab7a-a622f6774d95)

---
### Widgets

## [rf2_server](https://github.com/offer-shmuely/rf2-touch-suite-edgeTx/wiki/widget-rf2_server) - communication widget

background communication widget

![image](https://github.com/user-attachments/assets/89f7057b-8385-4e39-acff-27de3c8cd1c5)

* a must have background widget (that serve all other widget)
* it do all the communication to the FC
* should be installed on the topbar
* replace the original rf2bkg script
* replace the original rf2tlm script 
* new technology that detect elrs custom telemetry at correct order is already built-in (so no special procedure is needed for sensor discovery)

So, no need to define any scripts in special-function or custom-script anymore.

![alt text](docs/img/image-1.png)



## [rf2_dashboard](https://github.com/offer-shmuely/rf2-touch-suite-edgeTx/wiki/widget-%E2%80%90-rf2_dashboard) - dashboard widget
a dashboard of most needed info
* important RF2 telemetry 
* important elrs telemetry

![image](https://github.com/user-attachments/assets/9b95d285-7881-4286-883a-ad68321e9f7f)

## [rf2_dashboard](https://github.com/offer-shmuely/rf2-touch-suite-edgeTx/wiki/widget-%E2%80%90-rf2_dash-2) - dashboard widget
different style of dashboard

![image](https://github.com/user-attachments/assets/d2bcee9d-e5be-42a0-b2cc-868a900c5040)

## [rf2_name](https://github.com/offer-shmuely/rf2-touch-suite-edgeTx/wiki/widget-%E2%80%90-rf2_name) - name widget
used in single-tx-model (to many heli) configuration

* display the name of the heli that currently connected (not the name of the TX model)
* the name come from the ```<craft-name>``` that defined in the configurator
* when another heli connected the name automatically change 

## rf2_image - image widget
used in single-tx-model (to many heli) configuration

* display the image of the heli based on it's name
* the image should exist on ```/IMAGES/<craft-name>.png```
* when another heli connected the image automatically change
* it is NOT the image of the model as selected in the model-settings



---
<br><br><br>


## Requieremns
* Rotorflight 2.1.x and above
* edgeTx 2.10.x (currently, but will be deprecated soon)
* edgeTx 2.11.x
* color touch screen 480x272 resolution (radiomaster TX16s or similar)
* ELRS protocol (accst may be supported in the future)
* 
