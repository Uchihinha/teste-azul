sudo docker ps -a | grep -q azul-scrapper
sudo docker rm azul-scrapper || true
sudo docker image build -t azul-scrapper .
sudo docker run -i --name azul-scrapper -p 3000:3000 azul-scrapper