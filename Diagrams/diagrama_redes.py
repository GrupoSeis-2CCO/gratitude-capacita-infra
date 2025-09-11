from diagrams import Diagram, Edge, Cluster
from diagrams.aws.network import InternetGateway, RouteTable, ELB
from diagrams.aws.general import User
from diagrams.aws.compute import EC2
from diagrams.aws.storage import S3
from diagrams.custom import Custom
from diagrams.digitalocean.compute import Docker 
from diagrams.programming.language import Python
from diagrams.programming.language import Java
from diagrams.programming.framework import React
from diagrams.programming.framework import Spring
from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import SimpleNotificationServiceSns as SNS

with Diagram(
    name = "Diagrama de Rede Gratitude Capacita",
    direction="LR",
    graph_attr={
        "labelloc": "t",
        "fontsize": "36",
        "ranksep": "0.7",
        "nodesep": "0.3"
    },
    node_attr={"fontsize": "14"},
    show=True,
):
    usuario1 = User("Funcionario")
    usuario2 = User("Colaborador")
    computador = Custom("Computador", "Diagrams/Icons/Computer.png")

    [usuario1, usuario2] << Edge(color="black") >> computador

    with Cluster("AWS", graph_attr={"bgcolor": "#ff910030", "fontsize": "40", "fontcolor": "#cd7400"}):
        igw = InternetGateway("Internet Gateway")
        rt = RouteTable("Router Table")
        lb = ELB("Load Balancer")

        computador >> igw >> rt >> lb

        with Cluster("VPC", graph_attr={"bgcolor": "#262261A6", "fontsize": "20", "fontcolor": "#262261"}):
            with Cluster("Sub-rede Privada", graph_attr={"bgcolor": "#0033ff60", "fontsize": "16", "fontcolor": "#000000"}):
                with Cluster("Zona de disponibilidade us-east-1a", graph_attr={"bgcolor": "#747474e0", "fontsize": "14", "fontcolor": "#000000"}):
                    with Cluster("Security Group Privado 1", graph_attr={"fontcolor": "#000000"}):
                        mysql = Custom("MySQL", "Diagrams/Icons/MySQL.png")
                        ec2_priv_db = EC2("Ec2 Priv DB")
                    with Cluster("Security Group Privado 2", graph_attr={"fontcolor": "#000000"}):
                        java = Java("Java")
                        spring = Spring("Spring")
                        ec2_priv_be = EC2("Ec2 Priv BE")

            with Cluster("Sub-rede Pública", graph_attr={"bgcolor": "#26ff0060", "fontsize": "16", "fontcolor": "#000000"}):
                with Cluster("Zona de disponibilidade us-east-1a", graph_attr={"bgcolor": "#747474e0", "fontsize": "14", "fontcolor": "#000000"}):
                    with Cluster("Security Group Público", graph_attr={"fontcolor": "#000000"}):
                        ec2_pub_01 = EC2("Ec2 Pub 01")
                        react = React("React App")
                with Cluster("Zona de disponibilidade us-east-1b"):
                    with Cluster("Security Group Público", graph_attr={"fontcolor": "#000000"}):
                        ec2_pub_02 = EC2("Ec2 Pub 02")
                        react_icon = React("React App")

        # S3 e ETL cluster ao lado das sub-redes
        with Cluster("S3 e ETL", graph_attr={"bgcolor": "#e3f2fd", "fontcolor": "#000000"}):
            bronze = S3("BRONZE")
            silver = S3("SILVER")
            gold = S3("GOLD")
            etl_bs = Python("ETL BS Python")
            etl_sg = Python("ETL SG Python")

        with Cluster("Monitoramento", graph_attr={"bgcolor": "#e7157baa"}):
            cloudwatch = Cloudwatch("CloudWatch")
            sns = SNS("SNS")

        # Ligações horizontais
        ec2_pub_01 >> Edge(color="black") >> bronze     
        ec2_pub_02 >> Edge(color="black") >> bronze
        bronze >> Edge(color="bronze") >> etl_bs
        etl_bs >> Edge(color="silver") >> silver
        silver >> Edge(color="silver") >> etl_sg
        etl_sg >> Edge(color="gold") >> gold
        gold >> Edge(color="black") >> ec2_pub_01

        lb << Edge(color="green") >> ec2_pub_01
        lb << Edge(color="green") >> ec2_pub_02
        lb << Edge(color="blue") >> ec2_priv_be
        lb << Edge(color="blue") >> ec2_priv_db

