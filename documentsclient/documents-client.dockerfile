FROM python:3.8.3

RUN pip3 install elasticsearch
RUN pip3 install PyPDF2
RUN pip3 install fpdf

COPY resources /home/
