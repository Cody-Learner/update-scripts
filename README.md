# syuscript														<br>
<br>
Syuscript is a system update script used to provide additional pre and post system update information.			<br>
															<br>
The syuscript uses:													<br>
pacman -Syu for system updates												<br>
prep4ud script reports                : https://github.com/Cody-Learner/prep4ud 					<br>
A slightly modified overdue script by : https://github.com/tylerjl/overdue/blob/master/src/overdue.sh.			<br>
															<br>
															<br> 
Running syuscript:													<br>
(1) Prints latest prep4ud log, providing last update & reboot times + list updatable packages downloaded.		<br>
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