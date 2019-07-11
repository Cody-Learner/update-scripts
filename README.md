# syuscript														<br>
<br>
Script I use to provide info during system updates. 									<br>
															<br>
The syuscript uses:													<br>
The prep4ud script                               : https://github.com/Cody-Learner/prep4ud 				<br>
A slightly modified version of overdue script by : https://github.com/tylerjl/overdue/blob/master/src/overdue.sh.	<br>
															<br>
															<br> 
Running syuscript:													<br>
(1) Prints the last log of prep4ud showing which packages have already been downloaded for proceeding update.		<br>
(2) Runs 'sudo pacman -Syu'.												<br>
(3) Checks and prints results of a potential kernel update.								<br>
(4) Runs the overdue script to print systemd services to potentially restart.						<br>
															<br>
															<br>
I've set up an syuscript alias as 'Syu' in ~/.bashrc.									<br>
															<br>
Screenshot syuscript: https://cody-learner.github.io/syuscript.html							<br>
															<br>
															<br>