REM Disable Microsoft Edge Annoyances
REM Disables Microsoft Edge's first run experience.
REM Stops automatic sign-in in Edge.
REM Removes shopping features and rewards prompts.
REM Disables the default browser campaign.
REM Prevents auto-import and forced synchronization.
REM Turns off the sidebar and browser restore reminders.
REM Keeps the home button visible for easy navigation.
REM Ensures SmartScreen is enabled for enhanced security.
REM Disables popups about personalizing your browsing experience.
REM and much more as seen below...
REM You can place the values below under either key as needed:
REM 
REM HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge- mandatory settings
REM HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\Recommended - user can override settings


reg import .\EdgeCustomisation.reg /reg:64