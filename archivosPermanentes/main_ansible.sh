#!/usr/bin/env bash
ansible-playbook -i archivosPermanentes/dc0/inventory.yml archivosPermanentes/dc0/setup-ad.yml -u ubuntu --private-key ~/.ssh/id_ansible
ansible-playbook -i archivosPermanentes/cont/inventory.ini archivosPermanentes/cont/playbook.yml -u ubuntu --private-key ~/.ssh/id_ansible
ansible-playbook -i /home/ubuntu/archivosPermanentes/tpot/inventory.ini /home/ubuntu/archivosPermanentes/tpot/tpot.yml -u ubuntu --private-key /home/ubuntu/.ssh/id_ansible
