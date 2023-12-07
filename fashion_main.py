import os
from datetime import datetime
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.tensorboard import SummaryWriter

import torchvision.datasets as datasets
import torchvision.transforms as transforms
from agent_utils import Agent, Server
from tqdm import tqdm
from client_sampling import client_sampling
from log import log
from data_dist import get_data_sampler
from models.cnn_mnist import CNNMnist
from local_update import local_update_selected_clients
from config import get_parms


args = get_parms("Fashion-MNIST").parse_args()
args.cuda = not args.no_cuda and torch.cuda.is_available()
torch.manual_seed(args.seed)


kwargs = {"num_workers": 1, "pin_memory": True} if args.cuda else {}
current_loc = os.path.dirname(os.path.abspath(__file__))
transform = transforms.Compose(
    [transforms.ToTensor(), transforms.Normalize((0.5,), (0.5,))]
)

train_dataset = datasets.FashionMNIST(
    os.path.join(current_loc, "data", "fashion-mnist"),
    train=True,
    download=True,
    transform=transform,
)
test_dataset = datasets.FashionMNIST(
    os.path.join(current_loc, "data", "fashion-mnist"),
    train=False,
    download=True,
    transform=transform,
)
test_loader = torch.utils.data.DataLoader(
    test_dataset, batch_size=args.test_batch_size, shuffle=False, **kwargs
)

# Create clients and server
clients = []
for idx in range(args.num_clients):
    model = CNNMnist(args)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.SGD(
        model.parameters(), lr=args.lr, momentum=0.9, weight_decay=5e-4
    )
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=200)
    sampler = get_data_sampler(dataset=train_dataset, args=args, idx=idx)
    train_loader = torch.utils.data.DataLoader(
        train_dataset, batch_size=args.batch_size, sampler=sampler, **kwargs
    )
    clients.append(
        Agent(
            model=model,
            optimizer=optimizer,
            criterion=criterion,
            train_loader=train_loader,
        )
    )
server = Server(model=CNNMnist(args), criterion=criterion)


writer = SummaryWriter(
    os.path.join(
        "output",
        "fashion-mnist",
        f"alpha={args.alpha}+{args.sampling_type}+q={args.q}+num_clients={args.num_clients}+lr={args.lr}",
        # datetime.now().strftime("%m_%d-%H-%M-%S"),
    )
)

with tqdm(total=args.rounds, desc=f"Training:") as t:
    for round in range(0, args.rounds):
        sampled_clients = client_sampling(
            server.determine_sampling(args.q, args.sampling_type), clients, round
        )
        [client.pull_model_from_server(server) for client in sampled_clients]
        train_loss, train_acc = local_update_selected_clients(
            clients=sampled_clients, server=server, local_update=args.local_update
        )
        server.avg_clients(sampled_clients)
        writer.add_scalar("Loss/train", train_loss, round)
        writer.add_scalar("Accuracy/train", train_acc, round)
        t.set_postfix({"loss": train_loss, "accuracy": 100.0 * train_acc})
        t.update(1)
        if round % 10 == 0:
            eval_loss, eval_acc = server.eval(test_loader)
            writer.add_scalar("Loss/test", eval_loss, round)
            writer.add_scalar("Accuracy/test", eval_acc, round)
            print(f"Evaluation(round {round+1}): {eval_loss=:.4f} {eval_acc=:.3f}")
            log(round, eval_acc)

print(
    "Number of uniform participation rounds: " + str(server.get_num_uni_participation())
)
print(
    "Number of arbitrary participation rounds: "
    + str(server.get_num_arb_participation())
)
print("Ratio=" + str(server.get_num_arb_participation() / args.rounds))

eval_loss, eval_acc = server.eval(test_loader)
writer.add_scalar("Loss/test", eval_loss, round)
writer.add_scalar("Accuracy/test", eval_acc, round)
print(f"Evaluation(final round): {eval_loss=:.4f} {eval_acc=:.3f}")
writer.close()
