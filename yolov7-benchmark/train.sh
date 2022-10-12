#!/bin/bash
set -euo pipefail

dir=$(pwd)/runs/yolo-v7
echo $dir
datasets=$dir/rf100

if [ ! -d $datasets ] ; then
    $(pwd)/scripts/download_datasets.sh -l $datasets -f yolov5
fi

if [ ! -f "$dir/final_eval.txt" ] ; then
    touch "$dir/final_eval.txt"
fi


cd $(pwd)/yolov7-benchmark/

cd yolov7/

if [ ! -f "yolov7_training.pt" ] ; then
    wget https://github.com/WongKinYiu/yolov7/releases/download/v0.1/yolov7_training.pt
fi

for dataset in $(ls $datasets)
do
    dataset=$datasets/$dataset
    echo "Training on $dataset"
    if [ ! -d "$dataset/results" ] ;
    then
        python train.py --img 640 --batch 16 --epochs 100 --name $dataset/results --data $dataset/data.yaml  --weights 'yolov7_training.pt' |& tee $dataset/logs.txt 
        python test.py --data $dataset/data.yaml --img 640 --batch 16 --weights $dataset/results/weights/best.pt --name  $dataset --exist-ok |& tee $dataset/val_eval.txt 
        python ../parse_eval.py -i $dataset/val_eval.txt -l $dataset -o $dir/final_eval.txt
    fi
done

echo "Done training all the datasets with YOLOv7!"




