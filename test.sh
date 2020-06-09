#!/bin/bash
#"第一个参数是仓库别名，第二个参数是仓库地址，第三个参数是分支,第四个是提交的备注 第五个是提交的文件"
if [[ -d .git ]]; then
 echo "仓库存在"
else
 echo "初始化仓库"
 git init
 git remote add $1 $2
fi
#"判断参数1是否包含参数2"
contains_str(){
    # echo " >>> $1 <<< "
    # echo " <<< $2"
    
    contains_result=$(echo $1 | grep "${2}")
    if [[ -n $contains_result  ]] ; then
          return 1
      else
          return 0     
    fi
    
}
#提交到缓存中
git_add(){
    echo ">>>>>> 执行 git add 之前,本地文件状态如下 <<<<<<"
    git status 
    statusResult=$(git status)
    no_change="nothing to commit"

    contains_str "$statusResult" "$no_change"

    if [[ $? == 1 ]]; then
        echo "=== 当前没有新增或者修改的文件 ==="
        git_push
        exit
    else
        git add $5 
    fi     
}
#提交本地中
git_commit(){
     echo ">>>>>> 执行 git commit 之前,本地文件状态如下 <<<<<<"
     git status 
             if [ -z $4  ] ; then 
                 exit
             else
                 git commit  -m "$4" .    
             fi
}
git_push(){
    echo ">>>>>> 执行 git push 之前,本地文件状态如下 <<<<<<"
    git status 
    current_branch=$(git symbolic-ref --short -q HEAD) 
    echo ">>>>>> 当前分支:$current_branch <<<<<<"
    # "远程git地址别名,默认是origin: " 
    origin_params="origin" 
    echo -e "\n"
    # "远程分支名称,默认是当前分支: " 
    push_result="";
    if [[ -z $1 && -z $3 ]]; then
        echo ">>>>>> push origin $current_branch"
        sleep 5 
        git push -u origin $current_branch 

    elif [[ -n $1 && -n $3 ]]; then
        echo ">>>>>> push $1 $3"
        sleep 5 
        git push -u $1 $3

    elif [[ -z $1 && -n $3  ]]; then
        echo ">>>>>> push $origin_params $3"
        sleep 5
        git push -u $origin_params $3

    elif [[ -n $1 && -z $3  ]]; then
        echo ">>>>>> push $1 $current_branch"
        sleep 5 
        git push -u $1 $current_branch    
    else
        echo ">>>>>> end push <<<<<<"    
    fi
}
if [[ -z $3 ]]; then
        statusResult=$(git status)
        to_commit="Changes to be committed"
        contains_str "$statusResult" "$to_commit"
        if [[ $? != 1 ]]; then
            git_add;
        else 
            git add . 
            echo " ====== 本地没有需要add的文件，直接commit ====== "
        fi
        git_commit;
        git_push;
        exit;
elif [[ -n $3 ]]; then  
    git checkout $3
    echo -e "当前分支: \n $(git branch) "  
    git_add;
    git_commit;
	echo "--------------------------------"
    git_push;
    exit;
fi
