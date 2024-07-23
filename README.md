# syuscript																<br>
Syuscript is an update script used to provide pre and post system update information.							<br>
																	<br>
**The syuscript uses:**															<br>
`pacman -Syu` for system updates													<br>
Optionally if setup, `prep4ud` script reports: [prep4ud](https://github.com/Cody-Learner/prep4ud) 								<br>
A slightly modified overdue script by: [overdue.sh](https://github.com/tylerjl/overdue/blob/master/src/overdue.sh)			<br>
The `checkrebuild` script of Arch package: [rebuild-detector](https://archlinux.org/packages/extra/any/rebuild-detector/)		<br>
																	<br> 
**Running syuscript:**															<br>
(1) Optionally prints `prep4ud` report providing last update & reboot times + updatable packages downloaded.				<br>
(2) Runs `sudo pacman -Syu`.														<br>
(3) Checks and prints results if kernel is updated.											<br>
(4) Runs the `overdue` script to print services to consider restarting.									<br>
(5) Runs the `checkrebuild` script to print packages needing rebuilt.									<br>
																	<br>
I've set up an syuscript alias as `Syu` in ~/.bashrc.											<br>
																	<br>
Screenshot syuscript: https://cody-learner.github.io/syuscript.html									<br>
																	<br>																	<br>