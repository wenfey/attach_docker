# 自動補全腳本 for attach_docker
_attach_docker_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # 1. 遇到 --hold，絕對不補全 (等待輸入數字)
    if [[ "$prev" == "--hold" ]]; then
        COMPREPLY=()
        return 0
    fi

    # ==========================================
    # 🌟 守門員機制 (Grep 防雷升級版)
    # ==========================================
    local running_containers=$(docker ps --format '{{.Names}}')
    local has_container=0

    for word in "${COMP_WORDS[@]:1:$COMP_CWORD-1}"; do
        # 【防雷 1】只要是 - 開頭的選項，絕對不是容器，直接跳過！
        if [[ "$word" == -* ]]; then
            continue
        fi

        # 【防雷 2】加上 -F (純字串比對) 和 -- (停止解析參數)，確保 grep 絕對不會精神錯亂
        if echo "$running_containers" | grep -qxF -- "$word"; then
            has_container=1
            break
        fi
    done

    # 如果已經有容器了，且目前正在打的「不是」選項，封殺補全！
    if [[ $has_container -eq 1 && "$cur" != -* ]]; then
        COMPREPLY=()
        return 0
    fi
    # ==========================================

    # 2. 打造純淨版參數陣列
    local docker_args=()
    local i=1
    while [[ $i -lt $COMP_CWORD ]]; do
        local word="${COMP_WORDS[$i]}"
        if [[ "$word" == "--hold" ]]; then
            ((i+=2))
            continue
        elif [[ "$word" == "-h" || "$word" == "--help" ]]; then
            ((i++))
            continue
        else
            docker_args+=("$word")
            ((i++))
        fi
    done
    docker_args+=("$cur")

    # 3. 呼叫 Docker 的隱藏大腦
    local cobra_out
    cobra_out=$(docker __complete logs "${docker_args[@]}" 2>/dev/null)

    local filtered_reply=()

    # 4. 洗白結果
    while IFS=$'\n' read -r line; do
        local candidate="${line%%$'\t'*}"
        if [[ "$candidate" == :* ]]; then continue; fi
        if [[ "$candidate" == "-f" || "$candidate" == "--follow" ]]; then continue; fi

        # 二度防線
        if [[ $has_container -eq 1 && "$candidate" != -* ]]; then
            continue
        fi

        if [[ -n "$candidate" ]]; then
            filtered_reply+=("$candidate")
        fi
    done <<< "$cobra_out"

    # 5. 加入我們的私房選項
    if [[ "$cur" == -* ]]; then
        local custom_opts=$(compgen -W "--hold -h --help" -- "$cur")
        for cw in $custom_opts; do
            filtered_reply+=("$cw")
        done
    fi

    COMPREPLY=("${filtered_reply[@]}")
}

complete -F _attach_docker_complete attach_docker
