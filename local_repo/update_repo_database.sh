# build repo
repo-add repo.db.tar.gz pkg/*
sudo mkdir -p /etc/pacman.d/repo
sudo cp repo.* /etc/pacman.d/repo/
# sudo cp pkg/* /etc/pacman.d/repo/
sudo mkdir -p ../airootfs/etc/pacman.d/repo
sudo cp repo.* ../airootfs/etc/pacman.d/repo/
# sudo cp pkg/* ../airootfs/etc/pacman.d/repo/
