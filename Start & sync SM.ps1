# PowerShell script for running and syncing SM https://github.com/supermemo/SuperMemoScripts
# 这是一个 PowerShell 脚本（PowerShell 是 Windows 的一种命令行工具，可以运行这样的脚本文件）
# 它的作用是运行 SuperMemo (SM) 或 SuperMemo Assistant (SMA) 并使用 Git 来自动保存和同步你的 SuperMemo 收藏夹。
# 这个脚本的代码可以在这里找到：https://github.com/supermemo/SuperMemoScripts

# To be used with a git backup, as per https://www.supermemo.wiki/en/supermemo/backup-guide#internet-backups-git
# 这个脚本是用来配合 Git 备份使用的。你需要先设置好你的 SuperMemo 收藏夹的 Git 仓库。
# 具体怎么设置，可以参考这个指南：https://www.supermemo.wiki/en/supermemo/backup-guide#internet-backups-git (这是一个英文网页，如果你需要，我可以帮你看看里面的主要步骤)

# To run, put this script into your SM collection folder (the one with the .KNO file), right click the script and
# 要运行这个脚本，首先把这个脚本文件（就是你现在看的这个文件）放到你的 SuperMemo 收藏夹文件夹里。
# 这个文件夹就是你放 SuperMemo 收藏夹文件（比如叫做 collection.KNO 或者别的名字，但后缀是 .KNO）的地方。
# 然后，右键点击这个脚本文件，选择

# Sent to > Desktop. Then, right click the newly created shortcut and select Properties.
# "发送到" -> "桌面 (快捷方式)"。这会在你的桌面上创建一个运行这个脚本的快捷方式。
# 接着，右键点击这个新创建的桌面快捷方式，选择 "属性"。

# Depending whether you use SM or SMA, put the respective string below (replacing the correct path) in the Target field (ignoring the #) and press OK
# 根据你使用的是 SuperMemo (SM) 还是 SuperMemo Assistant (SMA)，把下面对应的那一行文字（需要把你自己的文件路径替换进去）放到快捷方式的 "目标" 框里。
# 复制的时候忽略掉开头的 # 号。改好路径后，点击 "确定" 保存。

# SM
# 如果你用的是 SuperMemo (SM) 的普通模式，把下面这行放进 "目标" 框：
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "& 'D:\path\to\Start & sync SM.ps1' C:\path\to\sm18.exe"
# 这行命令的意思是：
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe： 运行 Windows 的 PowerShell 程序。
# -command： 告诉 PowerShell 接下来是要运行一条命令。
# "& 'D:\path\to\Start & sync SM.ps1' C:\path\to\sm18.exe"： 这就是 PowerShell 要运行的具体命令。
# & ： 这是一个符号，告诉 PowerShell 后面跟着的是一个命令或者脚本，需要执行它。
# 'D:\path\to\Start & sync SM.ps1' ： 这是你的脚本文件在哪里（你需要改成你自己的真实路径，用单引号 ' ' 包起来，因为路径里有空格）。这是传给脚本的第一个参数 ($args[0])。
# 'C:\path\to\sm18.exe' ： 这是你的 SuperMemo 程序在哪里（你需要改成你自己的真实路径，用单引号 ' ' 包起来）。这是传给脚本的第二个参数 ($args[1])。

# SM + Pro mode
# 如果你用的是 SuperMemo (SM) 的专家模式 (--pro)，把下面这行放进 "目标" 框：
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "& 'D:\path\to\Start & sync SM.ps1' C:\path\to\sm18.exe --pro"
# 和上面类似，只是在 SuperMemo 程序路径后面多了一个 '--pro'。
# '--pro'： 这是一个告诉 **脚本** 要进入专家模式的标志。这是传给脚本的第三个参数 ($args[2])。脚本会识别到它。

# SMA
# 如果你用的是 SuperMemo Assistant (SMA) 的普通模式，把下面这行放进 "目标" 框：
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "& 'D:\path\to\Start & sync SM.ps1' C:\path\to\SuperMemoAssistant.exe"
# 意思和 SM 类似，只是把 SuperMemo 程序换成了 SuperMemo Assistant。

# SMA + Pro mode
# 如果你用的是 SuperMemo Assistant (SMA) 的专家模式 (--pro)，把下面这行放进 "目标" 框：
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "& 'D:\path\to\Start & sync SM.ps1' C:\path\to\SuperMemoAssistant.exe --pro"
# 意思也和 SM 类似，使用 SMA 并开启专家模式。

# 注意：上面的例子中，第一个单引号里的路径是脚本自己的路径，第二个单引号里（或者第二个单引号后）的路径是 SuperMemo 或 SMA 程序的路径。你需要把它们都换成你电脑上实际的路径。

# --- 脚本代码正文从这里开始 ---

# 这是一个函数（Function）。函数就像一个小工具，里面放了一些固定的步骤，你可以给这个小工具起个名字，以后需要这些步骤的时候，只需要叫一下这个名字就可以了。
# 这个函数叫做 Add-GitFiles，它的作用是把当前文件夹里所有文件的变化都告诉 Git，准备好保存。
function Add-GitFiles {
    # 这行命令是 Git 的命令。
    # git： 表示我们要运行 Git 这个程序。
    # add： 是 Git 的一个命令，意思是“添加”或者“暂存”。告诉 Git 我关注这些文件的变化。
    # -A： 这是一个选项，表示“所有” (All)。它会把所有 新增的、修改的、删除的文件 都包含进来。
    # *： 表示当前文件夹里的所有文件和文件夹。
    # 所以，git add -A * 的意思是：把当前文件夹里所有文件的变化（包括新增、修改、删除）都暂存起来，准备好进行下一次“拍照”保存 (commit)。
    git add -A *
}

# 这是另一个函数，叫做 Clear-CurrentFolder。这个函数用来“清理”当前文件夹，让它变得干净，和网上最新的保存记录一样。
# 它会丢弃你本地（在你电脑上）还没有保存的变化，然后从网上下载最新的版本。
# 注意：它会先尝试保存你本地还没保存的变化（放到一个叫做 "stash" 的地方），但主要目的是让当前文件夹回到干净状态。
function Clear-CurrentFolder {
    # 先调用上面那个 Add-GitFiles 函数，把当前的变化都暂存一下（虽然一会儿可能会丢弃，但先暂存是 git stash 的习惯）。
    Add-GitFiles
    # 这行是 Git 命令 git stash。
    # git stash： 意思是把当前工作目录中还没有提交（commit）的改动暂时存到一个叫做“贮藏区”（stash）的地方。
    # 这样，你的工作目录就会变得干净，和上一次提交的时候一样。你可以之后再回来找回这些暂存的改动。
    # 在这个脚本里，它的作用主要是为了让 git reset --hard 命令可以顺利执行，并且如果用户需要，之后可以找回这些改动。
    git stash
    # 这行是 Git 命令 git reset --hard。
    # git reset： 意思是重置。
    # --hard： 这是一个很“强硬”的选项。它会把你的工作目录（你看到的文件夹里的文件）完全恢复到最近一次提交 (commit) 的状态。
    # 它会丢弃所有还没有提交的改动（包括你刚刚 stash 的那些，如果你不手动找回的话）。
    # 在这里，它用来强制丢弃所有本地的未提交改动，让文件夹回到和远程仓库上次同步时一模一样的状态。
    git reset --hard
    # 这行是 Git 命令 git pull。
    # git pull： 意思是“拉取”。它会从远程仓库（网上的保存记录）下载最新的变化，并尝试和你的本地文件合并。
    # 这样你的本地文件夹就和网上的最新版本同步了。
    git pull
    # Read-Host 是 PowerShell 的一个命令，用来暂停脚本的执行，并等待用户在命令行窗口里输入一些文字，然后按回车键。
    # -Prompt： 后面的文字会显示给用户看，告诉用户需要做什么。
    # 这句话告诉用户，当前文件夹已经清理干净了，如果需要找回之前没保存的改动，可以去查一下“git stash”这个命令。
    # 然后脚本会等待用户按回车键才会继续执行。
    Read-Host "Current folder is now clean. Google `"git stash`" if you need to get your changes back. (Enter to continue)"
    # 注意：`" 在 PowerShell 里用来在字符串中包含双引号 "
}

# 这是第三个函数，叫做 Remove-UselessFiles。这个函数用于在专家模式下，检查 SuperMemo 关闭后是否只有少量变化。
# 如果变化很少，脚本会猜测这些可能是 SuperMemo 产生的一些不重要的临时文件，并询问用户是否要清理掉（不保存这些变化）。
function Remove-UselessFiles {
    # 运行 Git 命令 git status --porcelain=v1。
    # git status： 意思是查看当前工作目录和暂存区文件的状态，看看哪些文件被修改了、新增了或删除了。
    # --porcelain=v1： 这是一个选项，让输出的信息变得非常简洁、固定格式（像瓷器一样干净整齐），方便程序读取。v1 是格式的版本号。
    # 这行命令会把 Git 状态的简洁输出保存到变量 $cmdOutput 里。
    $cmdOutput = git status --porcelain=v1
    # 把 $cmdOutput 的内容打印出来，让用户看到 Git 的状态输出了什么。
    $cmdOutput
    # 这是一个条件判断 (if)。$cmdOutput.Count 表示 $cmdOutput 这个变量里有多少行文本。
    # -le： 意思是“小于或等于” (Less than or Equal to)。
    # if ($cmdOutput.Count -le 7)： 意思是“如果 Git status 的输出行数 小于或等于 7 行”。
    # 这个数字 7 是一个经验值，脚本作者认为如果状态输出只有几行，很可能只是 SuperMemo 产生的一些小变化，而不是用户做了很多重要的修改。
    if ($cmdOutput.Count -le 7) { # less or equals (小于或等于)
        # 如果条件成立（状态输出行数很少），打印提示信息，询问用户是否要清理。
        # Read-Host 会显示提示文字，并等待用户输入。
        # -Prompt： 提示文字。
        # 这句话说：“看起来 SuperMemo 打开后没做什么太多操作。输入 cl 来清理这些变化。”
        $userInput = Read-Host -Prompt "It seems that SM was opened and closed without performing many actions. Type cl to clear them."
        # 再次进行条件判断。检查用户输入的内容是否等于 "cl"。
        # -eq： 意思是“等于” (Equal to)。
        if ($userInput -eq "cl") {
            # 如果用户输入了 "cl"，就调用上面定义的 Clear-CurrentFolder 函数，执行清理操作。
            Clear-CurrentFolder
        }
    }
}

# --- 脚本开始执行的主体部分 ---

# 检查脚本运行时是否带有专家模式 (--pro) 参数。
# $args： 这是一个特殊的 PowerShell 变量，它是一个数组（一个列表），里面包含了运行脚本时传递给它的所有参数。
# $args.Count： $args 数组里有多少个参数。
# $args[$args.Count - 1]： 这是获取 $args 数组中的 最后一个 参数。数组的第一个元素索引是 0，所以最后一个元素的索引是 总数-1。
# -eq "--pro"： 检查最后一个参数是否等于字符串 "--pro"。
if ($args[$args.Count - 1] -eq "--pro") {
    # 如果最后一个参数是 "--pro"，就把变量 $proMode 设置为 $true（真），表示开启专家模式。
    $proMode = $true
    # 然后把 $args 数组中的最后一个参数设置为空 ($null)，这样在后面运行 SuperMemo 程序时就不会把 "--pro" 传给 SuperMemo 本身（除非 SuperMemo 程序也支持这个参数，但通常这个参数是给脚本自己用的）。
    $args[$args.Count - 1] = $null;
}

# 打印一行文字，告诉用户脚本正在执行 git pull 命令。
"git pull"
# 运行 Git 命令 git pull，从远程仓库拉取最新的变化。
git pull
# $LASTEXITCODE 是一个特殊的 PowerShell 变量，它保存着刚刚执行的最后一个外部程序（比如这里的 git）的退出代码。
# 通常情况下，程序成功执行的退出代码是 0。如果非 0，可能表示发生了错误或者有需要注意的情况。
# 把 git pull 命令的退出代码保存到变量 $pullCode 里。
$pullCode = $LASTEXITCODE

# 打印一行文字，告诉用户脚本正在执行 git status 命令。
"git status"
# 运行 Git 命令 git status --porcelain=v1，获取 Git 仓库的状态，使用简洁格式。
# cmd /c： 这是通过 Windows 的命令提示符 (cmd.exe) 来运行 git status。有时候这样写可以避免一些在 PowerShell 中直接运行 Git 命令可能遇到的问题。/c 表示执行后面的命令后关闭 cmd 窗口。
$statusOutput = cmd /c git status --porcelain=v1
# 检查 Git 状态输出或者之前的 git pull 是否有问题。
# $null -ne $statusOutput： 检查 $statusOutput 是否 不等于 (Not Equal to) $null。如果 Git status 有输出内容（哪怕是空行，或者提示有未跟踪文件等），$statusOutput 就不是 $null。这表示 Git 仓库不是完全干净的状态。
# -or： 这是一个逻辑词，表示“或者”。
# $pullCode： 检查变量 $pullCode 的值。如果它不是 0（也就是 git pull 有问题），这个条件也成立。
# 所以，if ($null -ne $statusOutput -or $pullCode) 的意思是：如果 Git 状态输出不是空的（表示有变化或问题） 或者 上一次 git pull 失败了。
if ($null -ne $statusOutput -or $pullCode) {
    # 如果条件成立（Git 状态不干净或 pull 有问题）：
    # 打印 Git status 的输出内容，让用户看到具体是什么问题。
    $statusOutput
    # 打印提示信息，告诉用户 Git 输出不正常，需要检查上面的内容。
    # "`r`n" 是 PowerShell 里表示回车和换行的特殊符号，用来创建空行。
    "`r`nNon standard git output - double check above"
    # 检查是否开启了专家模式。
    if ($proMode) {
        # 如果是专家模式，显示更多选项给用户。
        # Read-Host 显示提示信息，并等待用户输入。
        # 这句话问用户想做什么：输入 cl 清理未保存的改动（会备份到 stash），输入 diff 查看具体改动了什么。
        $userInput = Read-Host -Prompt "Type:`r`ncl if you want to clear any unsaved changes (backup will be stashed)`r`ndiff if you want to see what's actually changed (q to quit - if needed)"
        # 这是一个循环 (while)。只要用户输入的内容等于 "diff"，就一直重复执行循环里面的代码。
        while ($userInput -eq "diff") {
            # 在查看改动之前，先用 git add --intent-to-add . 命令。
            # git add --intent-to-add .： 这个命令会把当前目录下的所有文件添加到 Git 的索引中，但只是“假装”添加，并不会真正修改索引（不会把文件标记为已暂存 ready to commit）。
            # 它的主要作用是让 git diff 命令能比较出工作目录和上一次提交之间的所有改动（包括新增文件）。
            git add --intent-to-add .
            # 运行 git diff 命令，显示当前工作目录（以及假装暂存的）和上一次提交之间的具体差异。
            git diff
            # 再次显示提示信息，询问用户下一步做什么。用户可以继续输入 diff 看改动，输入 cl 清理，或者输入 q 退出这个循环。
            $userInput = Read-Host -Prompt "Type:`r`ncl if you want to clear any unsaved changes (backup will be stashed)`r`ndiff if you want to see what's actually changed (q to quit - if needed)"
        }
        # 在用户退出 diff 循环后，检查用户最后输入的内容是否是 "cl"。
        if ($userInput -eq "cl") {
            # 如果是 "cl"，调用 Clear-CurrentFolder 函数进行清理。
            Clear-CurrentFolder
        }
    } else {
        # 如果不是专家模式，遇到 Git 状态不干净或 pull 有问题时，只是显示提示，然后等待用户按回车继续。
        # 这样用户至少知道有问题发生，但没有专家模式那么多选项。
        Read-Host -Prompt "Press Enter to continue"
    }
} else {
    # 如果 Git 状态输出是空的（表示工作目录干净） 并且 git pull 成功（退出代码为 0）：
    # 打印提示信息，表示一切正常，继续执行脚本。
    "All OK - proceeding"
}

# --- 运行 SuperMemo ---

# 打印提示信息，告诉用户 SuperMemo 正在启动，脚本会在 SM 关闭后自动提交和推送变化。
# 也提醒用户如果不想保存变化，可以直接关闭这个命令行窗口。
"`r`nStarted SM, will commit changes on close. Close this terminal if you don't want that"
# 这行代码用来运行 SuperMemo 程序。
# & ： 这是 PowerShell 的调用操作符，用来执行一个命令或程序。
# $args[0]： 这是运行脚本时传递给脚本的 第一个参数。根据上面的说明，这个参数应该是 SuperMemo 或 SuperMemo Assistant 程序的完整路径。
# $args[1]： 这是运行脚本时传递给脚本的 第二个参数。根据上面的说明，如果在非专家模式下运行，这个参数可能是空的 ($null)；如果在专家模式下运行且 `--pro` 是最后一个参数，那么 `--pro` 已经被设置为 $null 了，所以这个参数也可能是空的。这里把 $args[1] 传给了 SuperMemo 程序。
# | Out-Null： 这部分叫做“管道”。它把前面命令（运行 SuperMemo 程序）的所有输出都发送给 Out-Null。
# Out-Null 的作用是丢弃所有接收到的输出。
# 更重要的是，当 PowerShell 使用 & 运行一个外部程序时，它会**暂停**脚本的执行，**等待**这个外部程序结束。
# 所以，这一行的作用就是：**启动 SuperMemo 程序，并等待你关闭 SuperMemo。在 SuperMemo 关闭之前，脚本会一直停在这里不往下走。**
& $args[0] $args[1] | Out-Null # start SM from provided path (&) and wait for it to close (Out-Null)
# 当 SuperMemo 程序关闭后，脚本就会继续往下执行，打印这行文字。
"Closed SM"

# --- SuperMemo 关闭后的处理 ---

# 检查是否开启了专家模式。
if ($proMode) {
    # 如果是专家模式，调用 Remove-UselessFiles 函数，检查并询问是否要清理掉 SuperMemo 关闭后产生的少量变化。
    Remove-UselessFiles
}

# 打印提示信息，告诉用户接下来要提交和推送变化了。
"Proceeding to commit & push changes"
# 调用 Add-GitFiles 函数，再次把当前文件夹里所有文件的变化都暂存起来，准备提交。
Add-GitFiles
# 运行 Git 命令 git commit。
# git commit： 意思是把当前暂存区里的变化正式“拍照”保存到 Git 的历史记录中。
# -m "PowerShell script update"： 这是一个选项，-m 表示“message”（消息）。后面跟着的是本次提交的说明文字。
# 这句命令会把所有暂存的变化保存为一个新的版本，并给这个版本起一个名字叫做 "PowerShell script update"。
# 注意：这个提交消息写得有点奇怪，它表示是“PowerShell 脚本更新”，而不是“SuperMemo 学习更新”。这可能会让人困惑。通常这里应该写一个更能反映你在 SM 里做了什么的消息，但脚本写死了就是这个。
git commit -m "PowerShell script update"

# 打印一行文字，告诉用户脚本正在执行 git pull 命令。
"git pull"
# 再次运行 Git 命令 git pull。在提交之后、推送之前再次拉取，是为了确保在你编辑 SuperMemo 期间，远程仓库没有被其他人修改。
# 如果有冲突，Git 会提示你。
git pull
# 再次把 git pull 命令的退出代码保存到变量 $pullCode 里。
$pullCode = $LASTEXITCODE

# 打印一行文字，告诉用户脚本正在执行 git push 命令。
"git push"
# 运行 Git 命令 git push。
# git push： 意思是把你的本地提交（刚刚那个“拍照”保存的版本）上传到远程仓库。
# -u： 这是一个选项，通常在你第一次推送到一个新分支时使用。它会把本地分支和远程分支关联起来（设置 upstream）。在这个脚本里每次都用 -u 可能是为了确保关联设置正确，即使分支名或远程仓库有变动。
git push -u

# 最后检查第二次 git pull 或者 git push 是否有问题。
# $pullCode： 检查第二次 git pull 的退出代码是否非 0。
# $LASTEXITCODE： 检查刚刚执行的 git push 的退出代码是否非 0。
# if ($pullCode -or $LASTEXITCODE)： 如果第二次 pull 有问题 或者 push 有问题。
if ($pullCode -or $LASTEXITCODE) {
    # 如果有问题，打印提示信息，告诉用户 Git 输出不正常，需要检查上面的内容。
    # 并等待用户按回车。
    Read-Host "`r`nNon standard git output - double check above"
}

# --- 脚本执行完毕 ---
# 脚本到这里就运行结束了。命令行窗口可能会保持打开状态，直到你关闭它（取决于你的 PowerShell 设置）。