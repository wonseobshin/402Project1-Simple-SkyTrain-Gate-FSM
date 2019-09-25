SkyTrain Gate FSM
====================
402 Project 1 Report
--------------------

By Won Seob Shin, 49820153

About
-----
This is a simple Fixed State Machine for an automated public transportation gate. The hardware only requires a sensor to detect NFC cards and software to know whether the card is valid or not. The software should compare the card's data and the database system to check whether the card pass is valid (active in the system) and whether it has enough balance. The machine then opens the door to valid pass holders and outputs to the software that an amount should be deducted through a signal, and show an error message if something is wrong to the user.


Fixed State Machine Diagram
---------------------------
![fsm block diagram](https://github.com/wonseobshin/402Project1-Simple-SkyTrain-Gate-FSM/blob/master/fsm.jpg)

Testbench Diagram
-----------------
![TB to FSM](https://github.com/wonseobshin/402Project1-Simple-SkyTrain-Gate-FSM/blob/master/DUT_diagram.jpg)

State Diagram
-------------
![State Transition](https://github.com/wonseobshin/402Project1-Simple-SkyTrain-Gate-FSM/blob/master/70769078_2362328880762682_2160517525123629056_n.jpg)

Wave
----
![wave diagram](https://github.com/wonseobshin/402Project1-Simple-SkyTrain-Gate-FSM/blob/master/wave.JPG)
