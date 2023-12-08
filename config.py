import argparse


# Parameters
def get_parms(dataset):
    parser = argparse.ArgumentParser(description="PyTorch" + str(dataset) + "trainning")
    parser.add_argument("--train-batch-size", type=int, default=64)
    parser.add_argument("--test-batch-size", type=int, default=1000)
    parser.add_argument("--lr", type=float, default=0.01, help="Learning rate")
    parser.add_argument("--sampling-type", type=str, default="uniform")
    parser.add_argument("--local-update", type=int, default=10, help="Local iterations")
    parser.add_argument("--num-clients", type=int, default=100, help="Total clients")
    parser.add_argument("--round", type=int, default=500, help="Communication rounds")
    parser.add_argument("--q", type=float, default=1, help="Probability")
    parser.add_argument("--alpha", type=float, default=0.1, help="Dirichlet parameter")
    parser.add_argument(
        "--data-dist", type=str, default="dirichlet", help="[uniform, dirichlet]"
    )
    parser.add_argument(
        "--no-cuda", action="store_true", default=False, help="disables CUDA training"
    )
    parser.add_argument(
        "--no-mps",
        action="store_true",
        default=False,
        help="disables macOS GPU training",
    )
    parser.add_argument("--epochs", type=int, default=100)
    parser.add_argument("--seed", type=int, default=53, help="random seed")
    return parser
