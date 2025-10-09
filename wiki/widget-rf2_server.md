## Background Communication Widget

This is a core widget required by all other widgets. It handles all communication (MSP) with the flight controller.

- Must be installed on the top bar  
- Replaces the original `rf2bkg` and `rf2tlm` scripts (they needed to be removed)
- Built-in support for ELRS RF2 custom telemetry (no special sensor discovery steps needed)  
- No need to define any scripts in Special Functions or Custom Scripts  

![image](https://github.com/user-attachments/assets/2e461ac2-7e7f-470d-b1d3-d20a74d9a48d)


## Telemetry detection 
when the heli is connected:
1. press "delete-all"
2. press "discover-new"
3. wait 10sec (until the *Cnt & *Skp shows)
4. press "stop"

![image](https://github.com/user-attachments/assets/510b5d96-083b-4d14-b06c-871d6d40eb4a)



