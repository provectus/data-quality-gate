FROM data-test:latest
RUN pip3 install pytest==7.3.1 moto==4.1.6
COPY ./test*.py ./
ENTRYPOINT ["pytest", "-qvs"]