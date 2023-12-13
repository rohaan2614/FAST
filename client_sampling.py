import torch
import numpy as np
import random


def client_sampling(sampling_type, clients, round):
    if sampling_type == "uniform":
        return uniform_client_sampling(clients)
    elif sampling_type == "gamma":
        return gamma_client_sampling(clients)
    elif sampling_type == "beta":
        return beta_client_sampling(clients)
    elif sampling_type == "markovian":
        return markovian_client_sampling(clients)
    elif sampling_type == "weibull":
        return weibull_client_sampling(clients)
    elif sampling_type == "cyclic":
        return cyclic_client_sampling(clients, round)
    elif sampling_type == "circular":
        return circular_client_sampling(clients, round)
    elif sampling_type == "dirichlet":
        return dirichlet_client_sampling(clients)
    else:
        raise Exception(f"Unsupported Sampling type: {sampling_type}. ")


def uniform_client_sampling(clients):
    sampled_clients = random.sample(clients, int(len(clients) * 0.1))
    return sampled_clients


def gamma_client_sampling(clients):
    shape = 1
    gamma_samples_indices = np.random.gamma(shape, size=int(len(clients) * 0.1))
    norm = np.linalg.norm(gamma_samples_indices)
    gamma_samples_indices = ((gamma_samples_indices / norm) * len(clients)).astype(int)
    sampled_clients = [clients[i] for i in gamma_samples_indices]
    return sampled_clients


def beta_client_sampling(clients):
    alpha = 20
    beta = 20
    beta_sample_indices = []
    while len(beta_sample_indices) < len(clients) * 0.1:
        idx = int(np.random.beta(alpha, beta, size=1) * len(clients))
        if idx not in beta_sample_indices:
            beta_sample_indices.append(idx)
    sampled_clients = [clients[i] for i in beta_sample_indices]
    return sampled_clients


# Cyclic client participation: Divide all clients into 5 groups.
def cyclic_client_sampling(clients, round):
    num_groups = 5
    length_each_group = int(len(clients) / num_groups)
    start_index = int((round % num_groups) * length_each_group)
    sampled_clients = np.random.choice(
        clients[start_index : start_index + length_each_group],
        size=int(len(clients) * 0.1),
        replace=False,
    )
    return sampled_clients


def circular_client_sampling(clients, round):
    num_groups = 10
    length_each_group = int(len(clients) / num_groups)
    start_index = int((round % num_groups) * length_each_group)
    print(f"start={start_index}")
    end_index = start_index + length_each_group
    sampled_clients = clients[start_index:end_index]
    return sampled_clients


def weibull_client_sampling(clients):
    shape = 0.01
    weibull_sample_indices = np.random.weibull(shape, size=int(len(clients) * 0.1))
    norm = np.linalg.norm(weibull_sample_indices)
    weibull_sample_indices = ((weibull_sample_indices / norm) * len(clients)).astype(
        int
    )
    sampled_clients = [clients[i] for i in weibull_sample_indices]
    return sampled_clients


def markovian_client_sampling(clients):
    transition_matrix = torch.tensor([[0.3, 0.7], [0.6, 0.4]])
    initial_distribution = torch.tensor([0.1, 0.9])
    current_state = torch.distributions.Categorical(initial_distribution).sample()
    sampled_clients = []
    for _ in range(int(len(clients) * 0.1)):
        # Generate the next state based on the current state
        next_state = torch.distributions.Categorical(
            transition_matrix[current_state]
        ).sample()
        # Append the current state as the sampled result
        sampled_clients.append(clients[next_state.item()])
        # Update the current state
        current_state = next_state
    return sampled_clients


def dirichlet_client_sampling(clients):
    alpha = 0.1
    # To do
