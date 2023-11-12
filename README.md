<img src="./figma-files.webp" alt="Global Figma File Launcher">

# Figma Files

FigmaFiles Spoon for HammerSpoon is a game-changer for Mac users, especially designers and developers. This innovative tool enables you to open Figma files from anywhere in your system with just a shortcut. Say goodbye to the hassle of navigating through teams and projects. Let's dive into how you can install and set up this nifty tool to streamline your workflow.

> [!IMPORTANT]
> Figma Files is provided as is. It is currently beta, but is functioning well enough for my needs. Please report any issues you may be experiencing and I willdo my best to resolve.

## Installing FigmaFiles Spoon for HammerSpoon

### 1. **Creating the Necessary Directory**

- Open your Terminal on your Mac.
- Create the required directory for HammerSpoon Spoons

     ```
     mkdir -p ~/.hammerspoon/Spoons
     ```

### 2. **Cloning the Figma Files Spoon Repository**

- In the Terminal, clone the FigmaFiles Spoon repository using the following command:

     ```
     git clone git@github.com:fyrebase/FigmaFiles.spoon.git ~/.hammerspoon/Spoons/FigmaFiles.spoon
     ```

     This command will download the necessary files into the directory you just created.

### 3. **Initializing the Spoon**

- To load the Spoon, add the following to your HammerSpoon `~/.hammerspoon/init.lua` file:

     ```
     hs.loadSpoon("FigmaFiles")
     ```

### 4. **Configuring the Spoon Settings**

- Now, it’s time to configure Figma Files. Add your Figma API key and the desired team IDs:

     ```
     spoon.FigmaFiles.apiKey = "[YOUR_FIGMA_API_KEY]"
     spoon.FigmaFiles.teamIds = {[TEAM_ID],[ANOTHER_TEAM_ID]}
     spoon.FigmaFiles.darkMode = true
     spoon.FigmaFiles.autoUpdate = true
     spoon.FigmaFiles.updateCacheInterval = 60*60*3 -- 3 Hours
     ```

     * Replace `[YOUR_FIGMA_API_KEY]` with your actual Figma API key.
     * Replace `[TEAM_ID],[ANOTHER_TEAM_ID]` with the team IDs you wish to access.

#### How to Obtain Your Figma API Key

- Visit the Figma website and log in.
- Navigate to your settings and look for API Key management. Here, you can generate or revoke your API key.
- Remember to replace `[YOUR_FIGMA_API_KEY]` in the script with the key you obtain.

#### Obtaining Team IDs

- Open the Figma desktop app.
- Right-click on your team and select 'Copy Link.'
- The URL will have your team ID at the end, like `https://www.figma.com/files/team/[TEAM_ID]`.

#### 5. **Activate the Figma Files Spoon**

     ```
     spoon.FigmaFiles:start()
     ```

#### 6. **Setting Up the Shortcut**

- Finally, set your preferred keyboard shortcut to open the Figma file chooser:

     ```
     spoon.FigmaFiles:bindHotKeys({
         showFigmaFilesChooser = {{ctrl, shift}, "f"}
     })
     ```

     This example sets `ctrl + shift + f` as the shortcut. Feel free to adjust it to your preference.

### Profit!
